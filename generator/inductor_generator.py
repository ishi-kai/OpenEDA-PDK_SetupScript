#!/bin/python3
# Inductor Generateor for FastHenry & GDS.
# Support Type : spiral, symmetry

import numpy as np
import random
import sys
import datetime
import pya
import os
import gdspy

import uuid
from enum import Enum


CELL_NAME = "INDUCTOR"
ORIGIN_XY = (0.0,0.0)
#TOP_METAL_LAYER = {"layer": 72, "datatype": 20}	# Sky130 of Metal5
#TOP_METAL_LAYER = {"layer": 71, "datatype": 20}		# Sky130 of Metal4
TOP_METAL_LAYER = {"layer": 10, "datatype": 0}		# OR1 of Metal2
#TOP_VIA_LAYER = {"layer": 70, "datatype": 44}		# Sky130 of VIA3
TOP_VIA_LAYER = {"layer": 9, "datatype": 0}		# OR1 of VIA1
#UNDER_METAL_LAYER = {"layer": 70, "datatype": 20}	# Sky130 of Metal3
UNDER_METAL_LAYER = {"layer": 8, "datatype": 0}	# OR1 of Metal1
VIA_SIZE = 1.0
VIA_MAT_SIZE = 1.6
#METAL_THICKNESS = 1.26				# um Thickness of Sky130 Metal5
#METAL_THICKNESS = 0.854				# um Thickness of Sky130 Metal4,3
METAL_THICKNESS = 0.854				# um Thickness of OR1 Metal2
#RHO_STR = "0.0285"				# ohm/sq of Sky130 Metal5
#RHO_STR = "0.047"				# ohm/sq of Sky130 Metal4,3
RHO_STR = "0.047"				# ohm/sq of OR1 Metal2
MIN_FREQ="1e1"
MAX_FREQ="1e6"


class InductorShapeType(Enum):
	spiral = 0
	hexagon = 1
	octagon = 2
	symmetry = 3

class InductorSideType(Enum):
	Top = 0
	Right = 1
	Bottom = 2
	Left = 3
	Start = 0
	End = 1

class InductorParams():
	def __init__(self, R, S, W, N, T, GuardRing_S, GuardRing_W):

		self.ID = uuid.uuid4()

		self.R = R				# InnerR
		self.S = S				# Wire2Wire Space
		self.W = W				# Wire Width
		self.N = int(N)				# Number of rolls
		self.L = 0.0				# Area Length. Cal by getL()
		self.A = 0.0				# Area Size. Cal by getA()
		self.T = T				# um Thickness


		self.GuardRing_S = GuardRing_S		# Guard Ring to Inductor Space 
		self.GuardRing_W = GuardRing_W		# Guard Ring Wire Width
		self.GuardRing_L = 0.0			# Guard Ring Length. Cal by getGuardRing_L()
		self.GuardRing_T = self.T		# um Thickness

		self.Tap_L = 10.0			# Tab Length

		self.center_xyz = (0.0, 0.0, 0.0)

		self.calL()
		self.calA()
		self.calGuardRing_L()
		self.calCenter()
		self.calTap_L()


	def calL(self):
		self.L = ( self.R/2.0 + (self.W*self.N) + (self.S*(self.N-1)) ) *2.0 	# Area Length
		return self.L

	def calA(self):
		self.A = self.L*self.L			# Area Size
		return self.A

	def calGuardRing_L(self):
		self.GuardRing_L = self.L + self.GuardRing_S*2.0 + self.GuardRing_W*2.0
		return self.GuardRing_L

	def calCenter(self):
		self.center_xyz = (self.GuardRing_L/2.0, self.GuardRing_L/2.0, self.T/2.0)
		return self.center_xyz

	def calTap_L(self):
		if self.Tap_L == 0.0:
			self.Tap_L = self.GuardRing_S	# um
		return self.Tap_L

	def calCenterPositonList(self):
		num_N_Center_List = []
		for num_N in range(int(self.N)):
			num_N = num_N + 1
			num_N_positon = self.R/2.0 + (self.W*num_N) - (self.W/2.0) + (self.S*(num_N-1))

			# InductorSideType.Top
			num_N_Center_xyz_T = (self.center_xyz[0], self.center_xyz[1]+num_N_positon, self.center_xyz[2])
			# InductorSideType.Bottom
			num_N_Center_xyz_B = (self.center_xyz[0], self.center_xyz[1]-num_N_positon, self.center_xyz[2])
			# InductorSideType.Left
			num_N_Center_xyz_L = (self.center_xyz[0]-num_N_positon, self.center_xyz[1], self.center_xyz[2])
			# InductorSideType.Right
			num_N_Center_xyz_R = (self.center_xyz[0]+num_N_positon, self.center_xyz[1], self.center_xyz[2])

			num_N_Center_xyz = (num_N_Center_xyz_T, num_N_Center_xyz_R, num_N_Center_xyz_B, num_N_Center_xyz_L)
			num_N_Center_List.append(num_N_Center_xyz)

		return num_N_Center_List

	def createBoxInductorPositonList(self):
		num_N_Center_List = self.calCenterPositonList()
		num_N = 0
		box_points_List = []
		for num_N_Center_TRBL in num_N_Center_List:
			num_N = num_N + 1
			# InductorSideType.Top
			num_N_Center_xyz_T = num_N_Center_TRBL[InductorSideType.Top.value]
			# InductorSideType.Bottom
			num_N_Center_xyz_B = num_N_Center_TRBL[InductorSideType.Bottom.value]
			# InductorSideType.Left
			num_N_Center_xyz_L = num_N_Center_TRBL[InductorSideType.Left.value]
			# InductorSideType.Right
			num_N_Center_xyz_R = num_N_Center_TRBL[InductorSideType.Right.value]

			num_N_L = self.R/2.0 + (self.W*num_N) + (self.S*(num_N-1))
			edge_W = (self.W/2.0)

			num_N_Box_Start_xyz_T = (num_N_Center_xyz_T[0] - num_N_L, num_N_Center_xyz_T[1] + edge_W, num_N_Center_xyz_T[2])
			num_N_Box_End_xyz_T = (num_N_Center_xyz_T[0] + num_N_L, num_N_Center_xyz_T[1] - edge_W, num_N_Center_xyz_T[2])
			
			num_N_Box_Start_xyz_B = (num_N_Center_xyz_B[0] - num_N_L, num_N_Center_xyz_B[1] + edge_W, num_N_Center_xyz_B[2])
			num_N_Box_End_xyz_B = (num_N_Center_xyz_B[0] + num_N_L, num_N_Center_xyz_B[1] - edge_W, num_N_Center_xyz_B[2])

			num_N_Box_Start_xyz_R = (num_N_Center_xyz_R[0] - edge_W, num_N_Center_xyz_R[1] - num_N_L, num_N_Center_xyz_R[2])
			num_N_Box_End_xyz_R = (num_N_Center_xyz_R[0] + edge_W, num_N_Center_xyz_R[1] + num_N_L, num_N_Center_xyz_R[2])

			num_N_Box_Start_xyz_L = (num_N_Center_xyz_L[0] - edge_W, num_N_Center_xyz_L[1] - num_N_L, num_N_Center_xyz_L[2])
			num_N_Box_End_xyz_L = (num_N_Center_xyz_L[0] + edge_W, num_N_Center_xyz_L[1] + num_N_L, num_N_Center_xyz_L[2])

			num_N_Box_points_T = (num_N_Box_Start_xyz_T, num_N_Box_End_xyz_T)
			num_N_Box_points_B = (num_N_Box_Start_xyz_B, num_N_Box_End_xyz_B)
			num_N_Box_points_R = (num_N_Box_Start_xyz_R, num_N_Box_End_xyz_R)
			num_N_Box_points_L = (num_N_Box_Start_xyz_L, num_N_Box_End_xyz_L)

			num_N_Box_points_List = (num_N_Box_points_T, num_N_Box_points_R, num_N_Box_points_B, num_N_Box_points_L)

			box_points_List.append(num_N_Box_points_List)

		return box_points_List

	def createLineInductorPositonList(self):
		num_N_Center_List = self.calCenterPositonList()
		num_N = 0
		line_points_List = []
		for num_N_Center_TRBL in num_N_Center_List:
			num_N = num_N + 1
			# InductorSideType.Top
			num_N_Center_xyz_T = num_N_Center_TRBL[InductorSideType.Top.value]
			# InductorSideType.Bottom1
			num_N_Center_xyz_B = num_N_Center_TRBL[InductorSideType.Bottom.value]
			# InductorSideType.Left
			num_N_Center_xyz_L = num_N_Center_TRBL[InductorSideType.Left.value]
			# InductorSideType.Right
			num_N_Center_xyz_R = num_N_Center_TRBL[InductorSideType.Right.value]

			edge_W = (self.W/2.0)
			num_N_L = self.R/2.0 + (self.W*num_N) + (self.S*(num_N-1)) - edge_W

			num_N_Line_Start_xyz_T = (num_N_Center_xyz_T[0] - num_N_L, num_N_Center_xyz_T[1], num_N_Center_xyz_T[2])
			num_N_Line_End_xyz_T = (num_N_Center_xyz_T[0] + num_N_L, num_N_Center_xyz_T[1], num_N_Center_xyz_T[2])
			
			num_N_Line_Start_xyz_B = (num_N_Center_xyz_B[0] + num_N_L, num_N_Center_xyz_B[1], num_N_Center_xyz_B[2])
			num_N_Line_End_xyz_B = (num_N_Center_xyz_B[0] - num_N_L, num_N_Center_xyz_B[1], num_N_Center_xyz_B[2])

			num_N_Line_Start_xyz_R = (num_N_Center_xyz_R[0], num_N_Center_xyz_R[1] + num_N_L, num_N_Center_xyz_R[2])
			num_N_Line_End_xyz_R = (num_N_Center_xyz_R[0], num_N_Center_xyz_R[1] - num_N_L, num_N_Center_xyz_R[2])

			num_N_Line_Start_xyz_L = (num_N_Center_xyz_L[0], num_N_Center_xyz_L[1] - num_N_L, num_N_Center_xyz_L[2])
			num_N_Line_End_xyz_L = (num_N_Center_xyz_L[0], num_N_Center_xyz_L[1] + num_N_L, num_N_Center_xyz_L[2])


			num_N_Line_points_T = (num_N_Line_Start_xyz_T, num_N_Line_End_xyz_T)
			num_N_Line_points_B = (num_N_Line_Start_xyz_B, num_N_Line_End_xyz_B)
			num_N_Line_points_R = (num_N_Line_Start_xyz_R, num_N_Line_End_xyz_R)
			num_N_Line_points_L = (num_N_Line_Start_xyz_L, num_N_Line_End_xyz_L)


			num_N_Line_points_List = (num_N_Line_points_T, num_N_Line_points_R, num_N_Line_points_B, num_N_Line_points_L)

			line_points_List.append(num_N_Line_points_List)

		return line_points_List

	def createBoxGuardRingPositonList(self):
		GR_Center_List = self.calCenterPositonList()

		GR_L = self.GuardRing_L / 2.0
		GR_edge_W = self.GuardRing_W / 2.0

		# InductorSideType.Top
		GR_Center_xyz_T = GR_Center_List[InductorSideType.Top.value]
		# InductorSideType.Bottom
		GR_Center_xyz_B = GR_Center_List[InductorSideType.Bottom.value]
		# InductorSideType.Left
		GR_Center_xyz_L = GR_Center_List[InductorSideType.Left.value]
		# InductorSideType.Right
		GR_Center_xyz_R = GR_Center_List[InductorSideType.Right.value]

		GR_Box_Start_xyz_T = (GR_Center_xyz_T[0] - GR_L, GR_Center_xyz_T[1] + GR_edge_W, GR_Center_xyz_T[2])
		GR_Box_End_xyz_T = (GR_Center_xyz_T[0] + GR_L, GR_Center_xyz_T[1] - GR_edge_W, GR_Center_xyz_T[2])
		
		GR_Box_Start_xyz_B = (GR_Center_xyz_B[0] - GR_L, GR_Center_xyz_B[1] + GR_edge_W, GR_Center_xyz_B[2])
		GR_Box_End_xyz_B = (GR_Center_xyz_B[0] + GR_L, GR_Center_xyz_B[1] - GR_edge_W, GR_Center_xyz_B[2])

		GR_Box_Start_xyz_R = (GR_Center_xyz_R[0] - GR_edge_W, GR_Center_xyz_R[1] - GR_L, GR_Center_xyz_R[2])
		GR_Box_End_xyz_R = (GR_Center_xyz_R[0] + GR_edge_W, GR_Center_xyz_R[1] + GR_L, GR_Center_xyz_R[2])

		GR_Box_Start_xyz_L = (GR_Center_xyz_L[0] - GR_edge_W, GR_Center_xyz_L[1] - GR_L, GR_Center_xyz_L[2])
		GR_Box_End_xyz_L = (GR_Center_xyz_L[0] + GR_edge_W, GR_Center_xyz_L[1] + GR_L, GR_Center_xyz_L[2])


		GR_Box_points_T = (GR_Box_Start_xyz_T, GR_Box_End_xyz_T)
		GR_Box_points_B = (GR_Box_Start_xyz_B, GR_Box_End_xyz_B)
		GR_Box_points_R = (GR_Box_Start_xyz_R, GR_Box_End_xyz_R)
		GR_Box_points_L = (GR_Box_Start_xyz_L, GR_Box_End_xyz_L)


		GR_Box_points_List = (GR_Box_points_T, GR_Box_points_R, GR_Box_points_B, GR_Box_points_L)

		return GR_Box_points_List


	def createLineGuardRingPositonList(self):
		GR_Center_List = self.calCenterPositonList()

		GR_L = self.GuardRing_L / 2.0
		GR_edge_W = self.GuardRing_W / 2.0

		# InductorSideType.Top
		GR_Center_xyz_T = GR_Center_List[InductorSideType.Top.value]
		# InductorSideType.Bottom
		GR_Center_xyz_B = GR_Center_List[InductorSideType.Bottom.value]
		# InductorSideType.Left
		GR_Center_xyz_L = GR_Center_List[InductorSideType.Left.value]
		# InductorSideType.Right
		GR_Center_xyz_R = GR_Center_List[InductorSideType.Right.value]

		GR_Line_Start_xyz_T = (GR_Center_xyz_T[0] - GR_L, GR_Center_xyz_T[1], GR_Center_xyz_T[2])
		GR_Line_End_xyz_T = (GR_Center_xyz_T[0] + GR_L, GR_Center_xyz_T[1], GR_Center_xyz_T[2])
		
		GR_Line_Start_xyz_B = (GR_Center_xyz_B[0] + GR_L, GR_Center_xyz_B[1], GR_Center_xyz_B[2])
		GR_Line_End_xyz_B = (GR_Center_xyz_B[0] - GR_L, GR_Center_xyz_B[1], GR_Center_xyz_B[2])

		GR_Line_Start_xyz_R = (GR_Center_xyz_R[0], GR_Center_xyz_R[1] + GR_L, GR_Center_xyz_R[2])
		GR_Line_End_xyz_R = (GR_Center_xyz_R[0], GR_Center_xyz_R[1] - GR_L, GR_Center_xyz_R[2])

		GR_Line_Start_xyz_L = (GR_Center_xyz_L[0], GR_Center_xyz_L[1] - GR_L, GR_Center_xyz_L[2])
		GR_Line_End_xyz_L = (GR_Center_xyz_L[0], GR_Center_xyz_L[1] + GR_L, GR_Center_xyz_L[2])


		GR_Line_points_T = (GR_Line_Start_xyz_T, GR_Line_End_xyz_T)
		GR_Line_points_B = (GR_Line_Start_xyz_B, GR_Line_End_xyz_B)
		GR_Line_points_R = (GR_Line_Start_xyz_R, GR_Line_End_xyz_R)
		GR_Line_points_L = (GR_Line_Start_xyz_L, GR_Line_End_xyz_L)


		GR_Line_points_List = (GR_Line_points_T, GR_Line_points_R, GR_Line_points_B, GR_Line_points_L)

		return GR_Line_points_List




class InductorGenerator():
	def __init__(self, shapeType, R, S, W, N, T, GuardRing_S, GuardRing_W):
		self.parameters = InductorParams(R, S, W, N, T, GuardRing_S, GuardRing_W)
		self.dt_now = datetime.datetime.now()
		self.shapeType = shapeType


	def generateInductor4gds(self):
		lib = gdspy.GdsLibrary()
		gdspy.current_library=gdspy.GdsLibrary()
		unitCell = lib.new_cell(CELL_NAME)

		if self.shapeType == InductorShapeType.spiral:
			self.generateInductorSpiral4gds_path(unitCell)
		elif self.shapeType == InductorShapeType.hexagon:
			print("Not implementation\n")
		elif self.shapeType == InductorShapeType.octagon:
			print("Not implementation\n")
		elif self.shapeType == InductorShapeType.symmetry:
			self.generateInductorSymmetry4gds_path(unitCell)
		else:
			print("Not implementation\n")


		top = lib.new_cell("TOP")
		top.add(unitCell)
		lib.write_gds("inductor_" + 
			str(self.dt_now.year) + 
			str(self.dt_now.month) + 
			str(self.dt_now.day) + 
			str(self.dt_now.hour) + 
			str(self.dt_now.minute) + 
			str(self.dt_now.second) + 
			".gds")


		return

	def generateInductorSpiral4gds_path(self, unitCell):
		linePositonList = self.parameters.createLineInductorPositonList()
		num_N_CenterList = self.parameters.calCenterPositonList()
		#lineNum = linePositonList.len()
		turxy_cnt = 0
		num_N = 0
		xy_cnt = 1
		xy_list = []
		xy_list.append(ORIGIN_XY)
		start_VIA_point = []

		for pointList in linePositonList:
			num_N_Center_TRBL = num_N_CenterList[num_N]
			turxy_cnt = turxy_cnt + 1
			num_N = num_N + 1

			num_N_Center_xyz_T = num_N_Center_TRBL[InductorSideType.Top.value]
			num_N_Center_xyz_B = num_N_Center_TRBL[InductorSideType.Bottom.value]

			points_T = pointList[InductorSideType.Top.value]
			points_B = pointList[InductorSideType.Bottom.value]
			points_R = pointList[InductorSideType.Right.value]
			points_L = pointList[InductorSideType.Left.value]

			points_T_start = points_T[InductorSideType.Start.value]
			points_T_end = points_T[InductorSideType.End.value]

			points_B_start = points_B[InductorSideType.Start.value]
			points_B_end = points_B[InductorSideType.End.value]

			points_R_start = points_R[InductorSideType.Start.value]
			points_R_end = points_R[InductorSideType.End.value]

			points_L_start = points_L[InductorSideType.Start.value]
			points_L_end = points_L[InductorSideType.End.value]

			# Right Side
			xy_point = (points_R_end[0], points_R_end[1])
			xy_list.append(xy_point)
			xy_cnt = xy_cnt + 1
			xy_point = (points_R_start[0], points_R_start[1])
			xy_list.append(xy_point)
			xy_cnt = xy_cnt + 1
			points = [(xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1]), (xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1])]
			path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
			unitCell.add(path)


			if num_N == 1:
				# VIA
				xy_point = (points_R_end[0] - self.parameters.W/2.0, points_R_end[1])
				via = gdspy.Rectangle((xy_point[0]-VIA_SIZE/2.0, xy_point[1]-VIA_SIZE/2.0), (xy_point[0]+VIA_SIZE/2.0, xy_point[1]+VIA_SIZE/2.0), **TOP_VIA_LAYER)
				unitCell.add(via)
				via = gdspy.Rectangle((xy_point[0]-VIA_MAT_SIZE/2.0, xy_point[1]-VIA_MAT_SIZE/2.0), (xy_point[0]+VIA_MAT_SIZE/2.0, xy_point[1]+VIA_MAT_SIZE/2.0), **TOP_METAL_LAYER)
				unitCell.add(via)
				via = gdspy.Rectangle((xy_point[0]-VIA_MAT_SIZE/2.0, xy_point[1]-VIA_MAT_SIZE/2.0), (xy_point[0]+VIA_MAT_SIZE/2.0, xy_point[1]+VIA_MAT_SIZE/2.0), **UNDER_METAL_LAYER)
				unitCell.add(via)
				start_VIA_point = (points_R_end[0], points_R_end[1])
			elif num_N == self.parameters.N:
				# Terminate Tap
				xy_point = (start_VIA_point[0], points_R_end[1] - self.parameters.GuardRing_S/2.0)
				points = [(start_VIA_point[0]-self.parameters.W/2.0, start_VIA_point[1]), (xy_point[0]-self.parameters.W/2.0, xy_point[1])]
				path = gdspy.FlexPath(points, self.parameters.W, **UNDER_METAL_LAYER)
				unitCell.add(path)

				
			# Upper Side
			xy_point = (points_T_end[0] + self.parameters.W/2.0, points_T_end[1])
			xy_list.append(xy_point)
			xy_cnt = xy_cnt + 1
			xy_point = (points_T_start[0] - self.parameters.W/2.0, points_T_start[1])
			xy_list.append(xy_point)
			xy_cnt = xy_cnt + 1
			points = [(xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1]), (xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1])]
			path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
			unitCell.add(path)

			# Left Side
			xy_point = (points_L_end[0], points_L_end[1])
			xy_list.append(xy_point)
			xy_cnt = xy_cnt + 1
			xy_point = (points_L_start[0], points_L_start[1] - self.parameters.S - self.parameters.W)
			xy_list.append(xy_point)
			xy_cnt = xy_cnt + 1
			points = [(xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1]), (xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1])]
			path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
			unitCell.add(path)
			
			# Bottom Side
			if num_N != self.parameters.N:
				xy_point = (points_B_start[0] + self.parameters.S + self.parameters.W + self.parameters.W/2.0, points_B_start[1] - self.parameters.S - self.parameters.W)
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
				xy_point = (points_B_end[0] - self.parameters.W/2.0, points_B_end[1] - self.parameters.S - self.parameters.W)
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
				points = [(xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1]), (xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1])]
				path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
				unitCell.add(path)



		# Terminate Tap
		xy_point = (points_L_start[0], points_L_start[1] - self.parameters.GuardRing_S/2.0)
		xy_list.append(xy_point)
		xy_cnt = xy_cnt + 1
		points = [(xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1]), (xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1])]
		path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
		unitCell.add(path)



		xy_point = (0, 0)
		xy_list.append(xy_point)
		xy_cnt = xy_cnt + 1
		xy_point = (self.parameters.GuardRing_L, 0)
		xy_list.append(xy_point)
		xy_cnt = xy_cnt + 1
		points = [(xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1]), (xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1])]
		path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
		unitCell.add(path)

		xy_point = (self.parameters.GuardRing_L, self.parameters.GuardRing_L)
		xy_list.append(xy_point)
		xy_cnt = xy_cnt + 1
		points = [(xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1]+self.parameters.W/2.0), (xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1]-self.parameters.W/2.0)]
		path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
		unitCell.add(path)

		xy_point = (0, self.parameters.GuardRing_L)
		xy_list.append(xy_point)
		xy_cnt = xy_cnt + 1
		points = [(xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1]), (xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1])]
		path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
		unitCell.add(path)

		points = [(xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1]+self.parameters.W/2.0), (xy_list[xy_cnt-4][0]-self.parameters.W/2.0, xy_list[xy_cnt-4][1]-self.parameters.W/2.0)]
		path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
		unitCell.add(path)

		return (xy_list)


	def generateInductorSymmetry4gds_path(self, unitCell):
		linePositonList = self.parameters.createLineInductorPositonList()
		num_N_CenterList = self.parameters.calCenterPositonList()
		#lineNum = linePositonList.len()
		turn_cnt = 0
		num_N = 0
		xy_cnt = 1
		xy_list = []
		xy_list.append(ORIGIN_XY)
		cross_L = self.parameters.W + self.parameters.S
		cross_L_half = cross_L / 2.0


		for pointList in linePositonList:
			num_N_Center_TRBL = num_N_CenterList[num_N]
			turn_cnt = turn_cnt + 1
			num_N = num_N + 1

			num_N_Center_xyz_T = num_N_Center_TRBL[InductorSideType.Top.value]
			num_N_Center_xyz_B = num_N_Center_TRBL[InductorSideType.Bottom.value]
			points_T_X_cross_start = num_N_Center_xyz_T[0] - cross_L_half
			points_T_X_cross_end = num_N_Center_xyz_T[0] + cross_L_half
			points_B_X_cross_start = num_N_Center_xyz_B[0] + cross_L_half
			points_B_X_cross_end = num_N_Center_xyz_B[0] - cross_L_half

			points_T = pointList[InductorSideType.Top.value]
			points_B = pointList[InductorSideType.Bottom.value]
			points_R = pointList[InductorSideType.Right.value]
			points_L = pointList[InductorSideType.Left.value]

			points_T_start = points_T[InductorSideType.Start.value]
			points_T_end = points_T[InductorSideType.End.value]

			points_B_start = points_B[InductorSideType.Start.value]
			points_B_end = points_B[InductorSideType.End.value]

			points_R_start = points_R[InductorSideType.Start.value]
			points_R_end = points_R[InductorSideType.End.value]

			points_L_start = points_L[InductorSideType.Start.value]
			points_L_end = points_L[InductorSideType.End.value]

			if num_N == 1:
				# Start Tap
				xy_point = (num_N_Center_xyz_B[0], num_N_Center_xyz_B[1]+self.parameters.R/2.0)
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
				xy_point = (num_N_Center_xyz_B[0], num_N_Center_xyz_B[1])
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
				points = [(xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1]), (xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1])]
				path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
				unitCell.add(path)

				xy_point = (points_B_start[0], points_B_start[1])
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
				xy_point = (points_L_start[0], points_L_start[1])
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
				points = [(xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1]), (xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1])]
				path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
				unitCell.add(path)

			elif num_N == self.parameters.N and num_N % 2 == 0:
				# Skip for Tap
				xy_point = (points_B_start[0], points_B_start[1])
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
				xy_point = (points_L_start[0], points_L_start[1])
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
			else:
				# Cross
				xy_point = (points_B_start[0], points_B_start[1])
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
				xy_point = (points_B_X_cross_start, points_B_start[1])
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
				points = [(xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1]), (xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1])]
				path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
				unitCell.add(path)

				xy_point = (points_B_X_cross_end, points_B_start[1])
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
				xy_point = (points_L_start[0], points_L_start[1])
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
				points = [(xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1]), (xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1])]
				path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
				unitCell.add(path)

				if num_N % 2 == 0:
					# VIA
					xy_point = (points_B_X_cross_end, points_B_start[1])
					via = gdspy.Rectangle((xy_point[0]-VIA_SIZE/2.0, xy_point[1]-VIA_SIZE/2.0), (xy_point[0]+VIA_SIZE/2.0, xy_point[1]+VIA_SIZE/2.0), **TOP_VIA_LAYER)
					unitCell.add(via)
					via = gdspy.Rectangle((xy_point[0]-VIA_MAT_SIZE/2.0, xy_point[1]-VIA_MAT_SIZE/2.0), (xy_point[0]+VIA_MAT_SIZE/2.0, xy_list[xy_cnt-1][1]+VIA_MAT_SIZE/2.0), **TOP_METAL_LAYER)
					unitCell.add(via)
					via = gdspy.Rectangle((xy_point[0]-VIA_MAT_SIZE/2.0, xy_point[1]-VIA_MAT_SIZE/2.0), (xy_point[0]+VIA_MAT_SIZE/2.0, xy_list[xy_cnt-1][1]+VIA_MAT_SIZE/2.0), **UNDER_METAL_LAYER)
					unitCell.add(via)

				else:
					# VIA
					xy_point = (points_B_X_cross_start, points_B_start[1])
					via = gdspy.Rectangle((xy_point[0]-VIA_SIZE/2.0, xy_point[1]-VIA_SIZE/2.0), (xy_point[0]+VIA_SIZE/2.0, xy_point[1]+VIA_SIZE/2.0), **TOP_VIA_LAYER)
					unitCell.add(via)
					via = gdspy.Rectangle((xy_point[0]-VIA_MAT_SIZE/2.0, xy_point[1]-VIA_MAT_SIZE/2.0), (xy_point[0]+VIA_MAT_SIZE/2.0, xy_list[xy_cnt-1][1]+VIA_MAT_SIZE/2.0), **TOP_METAL_LAYER)
					unitCell.add(via)
					via = gdspy.Rectangle((xy_point[0]-VIA_MAT_SIZE/2.0, xy_point[1]-VIA_MAT_SIZE/2.0), (xy_point[0]+VIA_MAT_SIZE/2.0, xy_list[xy_cnt-1][1]+VIA_MAT_SIZE/2.0), **UNDER_METAL_LAYER)
					unitCell.add(via)
					# Inner Connection
					points = [(xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1]), (xy_list[xy_cnt-11][0]-self.parameters.W/2.0, xy_list[xy_cnt-11][1])]
					path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
					unitCell.add(path)
					points = [(xy_list[xy_cnt-10][0]-self.parameters.W/2.0, xy_list[xy_cnt-10][1]), (xy_list[xy_cnt-3][0]-self.parameters.W/2.0, xy_list[xy_cnt-3][1])]
					path = gdspy.FlexPath(points, self.parameters.W, **UNDER_METAL_LAYER)
					unitCell.add(path)



			xy_point = (points_T_start[0], points_T_start[1])
			xy_list.append(xy_point)
			xy_cnt = xy_cnt + 1
			points = [(xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1]-self.parameters.W/2.0), (xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1]+self.parameters.W/2.0)]
			path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
			unitCell.add(path)



			if num_N == self.parameters.N and num_N % 2 == 1:
				# Skip for Tap
				xy_point = (points_R_start[0], points_R_start[1])
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
			else:
				# Cross
				xy_point = (points_T_X_cross_start, points_T_start[1])
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
				points = [(xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1]), (xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1])]
				path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
				unitCell.add(path)


				xy_point = (points_T_X_cross_end, points_T_start[1])
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1

				xy_point = (points_R_start[0], points_R_start[1])
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
				points = [(xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1]), (xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1])]
				path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
				unitCell.add(path)

				if num_N % 2 == 0:
					# VIA
					xy_point = (points_T_X_cross_end, points_T_start[1])
					via = gdspy.Rectangle((xy_point[0]-VIA_SIZE/2.0, xy_point[1]-VIA_SIZE/2.0), (xy_point[0]+VIA_SIZE/2.0, xy_point[1]+VIA_SIZE/2.0), **TOP_VIA_LAYER)
					unitCell.add(via)
					via = gdspy.Rectangle((xy_point[0]-VIA_MAT_SIZE/2.0, xy_point[1]-VIA_MAT_SIZE/2.0), (xy_point[0]+VIA_MAT_SIZE/2.0, xy_list[xy_cnt-1][1]+VIA_MAT_SIZE/2.0), **TOP_METAL_LAYER)
					unitCell.add(via)
					via = gdspy.Rectangle((xy_point[0]-VIA_MAT_SIZE/2.0, xy_point[1]-VIA_MAT_SIZE/2.0), (xy_point[0]+VIA_MAT_SIZE/2.0, xy_list[xy_cnt-1][1]+VIA_MAT_SIZE/2.0), **UNDER_METAL_LAYER)
					unitCell.add(via)
					if num_N == self.parameters.N:
						# Inner Connection
						points = [(xy_list[xy_cnt-3][0]-self.parameters.W/2.0, xy_list[xy_cnt-3][1]), (xy_list[xy_cnt-8][0]-self.parameters.W/2.0, xy_list[xy_cnt-8][1])]
						path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
						unitCell.add(path)
						points = [(xy_list[xy_cnt-9][0]-self.parameters.W/2.0, xy_list[xy_cnt-9][1]), (xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1])]
						path = gdspy.FlexPath(points, self.parameters.W, **UNDER_METAL_LAYER)
						unitCell.add(path)
					else:
						# Inner Connection
						points = [(xy_list[xy_cnt-3][0]-self.parameters.W/2.0, xy_list[xy_cnt-3][1]), (xy_list[xy_cnt-10][0]-self.parameters.W/2.0, xy_list[xy_cnt-10][1])]
						path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
						unitCell.add(path)
						points = [(xy_list[xy_cnt-11][0]-self.parameters.W/2.0, xy_list[xy_cnt-11][1]), (xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1])]
						path = gdspy.FlexPath(points, self.parameters.W, **UNDER_METAL_LAYER)
						unitCell.add(path)
				else:
					# VIA
					xy_point = (points_T_X_cross_start, points_T_start[1])
					via = gdspy.Rectangle((xy_point[0]-VIA_SIZE/2.0, xy_point[1]-VIA_SIZE/2.0), (xy_point[0]+VIA_SIZE/2.0, xy_point[1]+VIA_SIZE/2.0), **TOP_VIA_LAYER)
					unitCell.add(via)
					via = gdspy.Rectangle((xy_point[0]-VIA_MAT_SIZE/2.0, xy_point[1]-VIA_MAT_SIZE/2.0), (xy_point[0]+VIA_MAT_SIZE/2.0, xy_list[xy_cnt-1][1]+VIA_MAT_SIZE/2.0), **TOP_METAL_LAYER)
					unitCell.add(via)
					via = gdspy.Rectangle((xy_point[0]-VIA_MAT_SIZE/2.0, xy_point[1]-VIA_MAT_SIZE/2.0), (xy_point[0]+VIA_MAT_SIZE/2.0, xy_list[xy_cnt-1][1]+VIA_MAT_SIZE/2.0), **UNDER_METAL_LAYER)
					unitCell.add(via)





			if num_N == 1:
				points = [(xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1]+self.parameters.W/2.0), (xy_list[xy_cnt-6][0]-self.parameters.W/2.0, xy_list[xy_cnt-6][1]-self.parameters.W/2.0)]
				path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
				unitCell.add(path)
			elif num_N == self.parameters.N:
				points = [(xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1]+self.parameters.W/2.0), (xy_list[xy_cnt-6][0]-self.parameters.W/2.0, xy_list[xy_cnt-6][1]-self.parameters.W/2.0)]
				path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
				unitCell.add(path)
			else:
				points = [(xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1]+self.parameters.W/2.0), (xy_list[xy_cnt-8][0]-self.parameters.W/2.0, xy_list[xy_cnt-8][1]-self.parameters.W/2.0)]
				path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
				unitCell.add(path)


			# Terminate Tap
			if num_N == self.parameters.N and num_N % 2 == 0:
				# Non Bottom
				xy_point = (points_L_start[0], points_L_start[1] - self.parameters.GuardRing_S/2.0)
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
				points = [(xy_list[xy_cnt-6][0]-self.parameters.W/2.0, xy_list[xy_cnt-6][1]), (xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1])]
				path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
				unitCell.add(path)

				xy_point = (points_R_end[0], points_R_end[1] - self.parameters.GuardRing_S/2.0, points_R_end[2])
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
				points = [(xy_list[xy_cnt-8][0]-self.parameters.W/2.0, xy_list[xy_cnt-8][1]), (xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1])]
				path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
				unitCell.add(path)
			elif num_N == self.parameters.N and num_N % 2 == 1:
				# Non Upper
				xy_point = (points_L_end[0], points_L_end[1] + self.parameters.GuardRing_S/2.0)
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
				points = [(xy_list[xy_cnt-3][0]-self.parameters.W/2.0, xy_list[xy_cnt-3][1]), (xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1])]
				path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
				unitCell.add(path)

				xy_point = (points_R_start[0], points_R_start[1] + self.parameters.GuardRing_S/2.0, points_R_start[2])
				xy_list.append(xy_point)
				xy_cnt = xy_cnt + 1
				points = [(xy_list[xy_cnt-8][0]-self.parameters.W/2.0, xy_list[xy_cnt-8][1]), (xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1])]
				path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
				unitCell.add(path)


		xy_point = (0, 0)
		xy_list.append(xy_point)
		xy_cnt = xy_cnt + 1
		xy_point = (self.parameters.GuardRing_L, 0)
		xy_list.append(xy_point)
		xy_cnt = xy_cnt + 1
		points = [(xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1]), (xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1])]
		path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
		unitCell.add(path)

		xy_point = (self.parameters.GuardRing_L, self.parameters.GuardRing_L)
		xy_list.append(xy_point)
		xy_cnt = xy_cnt + 1
		points = [(xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1]+self.parameters.W/2.0), (xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1]-self.parameters.W/2.0)]
		path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
		unitCell.add(path)

		xy_point = (0, self.parameters.GuardRing_L)
		xy_list.append(xy_point)
		xy_cnt = xy_cnt + 1
		points = [(xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1]), (xy_list[xy_cnt-2][0]-self.parameters.W/2.0, xy_list[xy_cnt-2][1])]
		path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
		unitCell.add(path)

		points = [(xy_list[xy_cnt-1][0]-self.parameters.W/2.0, xy_list[xy_cnt-1][1]+self.parameters.W/2.0), (xy_list[xy_cnt-4][0]-self.parameters.W/2.0, xy_list[xy_cnt-4][1]-self.parameters.W/2.0)]
		path = gdspy.FlexPath(points, self.parameters.W, **TOP_METAL_LAYER)
		unitCell.add(path)

		return



	def generateInductor4henry(self):
		body_str = ""

		if self.shapeType == InductorShapeType.spiral:
			body_str = self.generateInductorSpiral4henry_wire()
		elif self.shapeType == InductorShapeType.hexagon:
			print("Not implementation\n")
		elif self.shapeType == InductorShapeType.octagon:
			print("Not implementation\n")
		elif self.shapeType == InductorShapeType.symmetry:
			body_str = self.generateInductorSymmetry4henry_wire()
		else:
			print("Not implementation\n")


		point_Line_List = body_str[2]

		header_str = "** Autogenerated ind \n"
		footer_str = "\n"

		header_str = header_str + ".units um \n"
		header_str = header_str + ".Default sigma=5.8e4 nhinc=5 nwinc=5 \n\n"

		footer_str = footer_str + ".external " + body_str[1] + "\n"
		footer_str = footer_str + ".freq fmin=" + MIN_FREQ + " fmax=" + MAX_FREQ + " ndec=10\n"
		footer_str = footer_str + "\n.end\n"

		for n in point_Line_List:
			print(n)

		dt_now = datetime.datetime.now()
		file_name = ("inductor_" + 
			str(self.dt_now.year) + 
			str(self.dt_now.month) + 
			str(self.dt_now.day) + 
			str(self.dt_now.hour) + 
			str(self.dt_now.minute) + 
			str(self.dt_now.second) + 
			".inp")

		f = open(file_name, 'w')
		f.write(header_str)
		f.write(body_str[0])
		f.write(footer_str)
		f.close()
		return

	def generateInductorSpiral4henry_wire(self):
		linePositonList = self.parameters.createLineInductorPositonList()
		num_N_CenterList = self.parameters.calCenterPositonList()
		#lineNum = linePositonList.len()
		turn_cnt = 0
		num_N = 0
		N_cnt = 1
		E_cnt = 1
		NV_cnt = 1
		henry_N_str = ""
		henry_N_list = []
		henry_N_list.append("dummy")
		henry_E_str = ""
		henry_Tap_str = ""
		point_Line_List = []
		via_L = self.parameters.T * 2.0
		start_VIA_point = []

		for pointList in linePositonList:
			num_N_Center_TRBL = num_N_CenterList[num_N]
			turn_cnt = turn_cnt + 1
			num_N = num_N + 1

			num_N_Center_xyz_T = num_N_Center_TRBL[InductorSideType.Top.value]
			num_N_Center_xyz_B = num_N_Center_TRBL[InductorSideType.Bottom.value]

			points_T = pointList[InductorSideType.Top.value]
			points_B = pointList[InductorSideType.Bottom.value]
			points_R = pointList[InductorSideType.Right.value]
			points_L = pointList[InductorSideType.Left.value]

			points_T_start = points_T[InductorSideType.Start.value]
			points_T_end = points_T[InductorSideType.End.value]

			points_B_start = points_B[InductorSideType.Start.value]
			points_B_end = points_B[InductorSideType.End.value]

			points_R_start = points_R[InductorSideType.Start.value]
			points_R_end = points_R[InductorSideType.End.value]

			points_L_start = points_L[InductorSideType.Start.value]
			points_L_end = points_L[InductorSideType.End.value]

			# Right Side
			if num_N == 1:
				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_R_end[0], points_R_end[1], points_R_end[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
			formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_R_start[0], points_R_start[1], points_R_start[2])
			henry_N_str = henry_N_str + formatted_msg
			henry_N_list.append(formatted_msg)
			N_cnt = N_cnt + 1
			formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-2, N_cnt-1, RHO_STR, self.parameters.T, self.parameters.W)
			henry_E_str = henry_E_str + formatted_msg
			point_Line_List.append((henry_N_list[N_cnt-2], henry_N_list[N_cnt-1]))
			E_cnt = E_cnt + 1
			if num_N == 1:
				# VIA
				formatted_msg = 'NV%d x=%f y=%f z=%f \n' % (NV_cnt, points_R_end[0], points_R_end[1], points_R_end[2] - via_L)
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				NV_cnt = NV_cnt + 1
				formatted_msg = 'E%d NV%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, NV_cnt-1, N_cnt-2, RHO_STR, via_L, self.parameters.T)
				henry_E_str = henry_E_str + formatted_msg
				E_cnt = E_cnt + 1
				start_VIA_point = points_R_end
			elif num_N == self.parameters.N:
				# VIA
				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, start_VIA_point[0], points_R_end[1] - self.parameters.GuardRing_S/2.0, points_R_end[2] - via_L)
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
				formatted_msg = 'E%d NV%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, NV_cnt-1, N_cnt-1, RHO_STR, self.parameters.T, self.parameters.W)
				henry_E_str = henry_E_str + formatted_msg
				E_cnt = E_cnt + 1
				# Terminate Tap
				henry_Tap_str = "N" + str(N_cnt - 1)

				
			# Upper Side
			formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_T_start[0], points_T_start[1], points_T_start[2])
			henry_N_str = henry_N_str + formatted_msg
			henry_N_list.append(formatted_msg)
			N_cnt = N_cnt + 1
			if num_N == self.parameters.N:
				formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-3, N_cnt-1, RHO_STR, self.parameters.T, self.parameters.W)
			else:
				formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-2, N_cnt-1, RHO_STR, self.parameters.T, self.parameters.W)

			henry_E_str = henry_E_str + formatted_msg
			point_Line_List.append((henry_N_list[N_cnt-2], henry_N_list[N_cnt-1]))
			E_cnt = E_cnt + 1

			# Left Side
			formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_L_start[0], points_L_start[1] - self.parameters.S - self.parameters.W, points_L_start[2])
			henry_N_str = henry_N_str + formatted_msg
			henry_N_list.append(formatted_msg)
			N_cnt = N_cnt + 1
			formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-2, N_cnt-1, RHO_STR, self.parameters.T, self.parameters.W)
			henry_E_str = henry_E_str + formatted_msg
			point_Line_List.append((henry_N_list[N_cnt-2], henry_N_list[N_cnt-1]))
			E_cnt = E_cnt + 1
			
			# Bottom Side
			if num_N != self.parameters.N:
				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_B_start[0] + self.parameters.S + self.parameters.W, points_B_start[1] - self.parameters.S - self.parameters.W, points_B_start[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
				formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-2, N_cnt-1, RHO_STR, self.parameters.T, self.parameters.W)
				henry_E_str = henry_E_str + formatted_msg
				point_Line_List.append((henry_N_list[N_cnt-2], henry_N_list[N_cnt-1]))
				E_cnt = E_cnt + 1



		# Terminate Tap
		formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_L_start[0], points_L_start[1] - self.parameters.GuardRing_S/2.0, points_L_start[2])
		henry_N_str = henry_N_str + formatted_msg
		henry_N_list.append(formatted_msg)
		N_cnt = N_cnt + 1
		formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-2, N_cnt-1, RHO_STR, self.parameters.T, self.parameters.W)
		henry_E_str = henry_E_str + formatted_msg
		point_Line_List.append((henry_N_list[N_cnt-2], henry_N_list[N_cnt-1]))
		E_cnt = E_cnt + 1
		henry_Tap_str = henry_Tap_str + " N" + str(N_cnt - 1)



		formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, 0, 0, self.parameters.GuardRing_T / 2.0)
		henry_N_str = henry_N_str + formatted_msg
		henry_N_list.append(formatted_msg)
		N_cnt = N_cnt + 1
		formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, self.parameters.GuardRing_L, 0, self.parameters.GuardRing_T / 2.0)
		henry_N_str = henry_N_str + formatted_msg
		henry_N_list.append(formatted_msg)
		N_cnt = N_cnt + 1
		formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-1, N_cnt-2, RHO_STR, self.parameters.T, self.parameters.W)
		henry_E_str = henry_E_str + formatted_msg
		point_Line_List.append((henry_N_list[N_cnt-1], henry_N_list[N_cnt-2]))
		E_cnt = E_cnt + 1

		formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, self.parameters.GuardRing_L, self.parameters.GuardRing_L, self.parameters.GuardRing_T / 2.0)
		henry_N_str = henry_N_str + formatted_msg
		henry_N_list.append(formatted_msg)
		N_cnt = N_cnt + 1
		formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-1, N_cnt-2, RHO_STR, self.parameters.T, self.parameters.W)
		henry_E_str = henry_E_str + formatted_msg
		point_Line_List.append((henry_N_list[N_cnt-1], henry_N_list[N_cnt-2]))
		E_cnt = E_cnt + 1

		formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, 0, self.parameters.GuardRing_L, self.parameters.GuardRing_T / 2.0)
		henry_N_str = henry_N_str + formatted_msg
		henry_N_list.append(formatted_msg)
		N_cnt = N_cnt + 1
		formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-1, N_cnt-2, RHO_STR, self.parameters.T, self.parameters.W)
		henry_E_str = henry_E_str + formatted_msg
		point_Line_List.append((henry_N_list[N_cnt-1], henry_N_list[N_cnt-2]))
		E_cnt = E_cnt + 1

		formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-1, N_cnt-4, RHO_STR, self.parameters.T, self.parameters.W)
		henry_E_str = henry_E_str + formatted_msg
		point_Line_List.append((henry_N_list[N_cnt-1], henry_N_list[N_cnt-4]))
		E_cnt = E_cnt + 1

		print (henry_N_str)
		print (henry_E_str)
		print (henry_Tap_str)
		return ((henry_N_str + "\n" + henry_E_str), henry_Tap_str, point_Line_List)


	def generateInductorSymmetry4henry_wire(self):
		linePositonList = self.parameters.createLineInductorPositonList()
		num_N_CenterList = self.parameters.calCenterPositonList()
		#lineNum = linePositonList.len()
		turn_cnt = 0
		num_N = 0
		N_cnt = 1
		E_cnt = 1
		NV_cnt = 1
		henry_N_str = ""
		henry_N_list = []
		henry_N_list.append("dummy")
		henry_E_str = ""
		henry_Tap_str = ""
		point_Line_List = []
		cross_L = self.parameters.W + self.parameters.S
		cross_L_half = cross_L / 2.0
		via_L = self.parameters.T * 2.0

		for pointList in linePositonList:
			num_N_Center_TRBL = num_N_CenterList[num_N]
			turn_cnt = turn_cnt + 1
			num_N = num_N + 1

			num_N_Center_xyz_T = num_N_Center_TRBL[InductorSideType.Top.value]
			num_N_Center_xyz_B = num_N_Center_TRBL[InductorSideType.Bottom.value]
			points_T_X_cross_start = num_N_Center_xyz_T[0] - cross_L_half
			points_T_X_cross_end = num_N_Center_xyz_T[0] + cross_L_half
			points_B_X_cross_start = num_N_Center_xyz_B[0] + cross_L_half
			points_B_X_cross_end = num_N_Center_xyz_B[0] - cross_L_half

			points_T = pointList[InductorSideType.Top.value]
			points_B = pointList[InductorSideType.Bottom.value]
			points_R = pointList[InductorSideType.Right.value]
			points_L = pointList[InductorSideType.Left.value]

			points_T_start = points_T[InductorSideType.Start.value]
			points_T_end = points_T[InductorSideType.End.value]

			points_B_start = points_B[InductorSideType.Start.value]
			points_B_end = points_B[InductorSideType.End.value]

			points_R_start = points_R[InductorSideType.Start.value]
			points_R_end = points_R[InductorSideType.End.value]

			points_L_start = points_L[InductorSideType.Start.value]
			points_L_end = points_L[InductorSideType.End.value]

			if num_N == 1:
				# Start Tap
				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, num_N_Center_xyz_B[0], num_N_Center_xyz_B[1]+self.parameters.R/2.0, num_N_Center_xyz_B[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, num_N_Center_xyz_B[0], num_N_Center_xyz_B[1], num_N_Center_xyz_B[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
				formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-2, N_cnt-1, RHO_STR, self.parameters.T, self.parameters.W)
				henry_E_str = henry_E_str + formatted_msg
				point_Line_List.append((henry_N_list[N_cnt-2], henry_N_list[N_cnt-1]))
				E_cnt = E_cnt + 1

				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_B_start[0], points_B_start[1], points_B_start[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_L_start[0], points_L_start[1], points_L_start[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
				formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-2, N_cnt-1, RHO_STR, self.parameters.T, self.parameters.W)
				henry_E_str = henry_E_str + formatted_msg
				point_Line_List.append((henry_N_list[N_cnt-2], henry_N_list[N_cnt-1]))
				E_cnt = E_cnt + 1

			elif num_N == self.parameters.N and num_N % 2 == 0:
				# Skip for Tap
				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_B_start[0], points_B_start[1], points_B_start[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_L_start[0], points_L_start[1], points_L_start[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
			else:
				# Cross
				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_B_start[0], points_B_start[1], points_B_start[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_B_X_cross_start, points_B_start[1], points_B_start[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
				formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-2, N_cnt-1, RHO_STR, self.parameters.T, self.parameters.W)
				henry_E_str = henry_E_str + formatted_msg
				point_Line_List.append((henry_N_list[N_cnt-2], henry_N_list[N_cnt-1]))
				E_cnt = E_cnt + 1

				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_B_X_cross_end, points_B_start[1], points_B_start[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1

				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_L_start[0], points_L_start[1], points_L_start[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
				formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-2, N_cnt-1, RHO_STR, self.parameters.T, self.parameters.W)
				henry_E_str = henry_E_str + formatted_msg
				point_Line_List.append((henry_N_list[N_cnt-2], henry_N_list[N_cnt-1]))
				E_cnt = E_cnt + 1

				if num_N % 2 == 0:
					# VIA
					formatted_msg = 'NV%d x=%f y=%f z=%f \n' % (NV_cnt, points_B_X_cross_end, points_B_start[1], points_B_start[2] - via_L)
					henry_N_str = henry_N_str + formatted_msg
					henry_N_list.append(formatted_msg)
					NV_cnt = NV_cnt + 1
					formatted_msg = 'E%d NV%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, NV_cnt-1, N_cnt-2, RHO_STR, via_L, self.parameters.T)
					henry_E_str = henry_E_str + formatted_msg
					E_cnt = E_cnt + 1
				else:
					# VIA
					formatted_msg = 'NV%d x=%f y=%f z=%f \n' % (NV_cnt, points_B_X_cross_start, points_B_start[1], points_B_start[2] - via_L)
					henry_N_str = henry_N_str + formatted_msg
					NV_cnt = NV_cnt + 1
					formatted_msg = 'E%d NV%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, NV_cnt-1, N_cnt-3, RHO_STR, via_L, self.parameters.T)
					henry_E_str = henry_E_str + formatted_msg
					E_cnt = E_cnt + 1
					# Inner Connection
					formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-2, N_cnt-11, RHO_STR, self.parameters.T, self.parameters.W)
					henry_E_str = henry_E_str + formatted_msg
					E_cnt = E_cnt + 1
					formatted_msg = 'E%d NV%d NV%d rho=%s  H=%f W=%f \n' % (E_cnt, NV_cnt-1, NV_cnt-3, RHO_STR, self.parameters.T, self.parameters.W)
					henry_E_str = henry_E_str + formatted_msg
					E_cnt = E_cnt + 1



			formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_T_start[0], points_T_start[1], points_T_start[2])
			henry_N_str = henry_N_str + formatted_msg
			henry_N_list.append(formatted_msg)
			N_cnt = N_cnt + 1
			formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-2, N_cnt-1, RHO_STR, self.parameters.T, self.parameters.W)
			henry_E_str = henry_E_str + formatted_msg
			point_Line_List.append((henry_N_list[N_cnt-2], henry_N_list[N_cnt-1]))
			E_cnt = E_cnt + 1



			if num_N == self.parameters.N and num_N % 2 == 1:
				# Skip for Tap
				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_R_start[0], points_R_start[1], points_R_start[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
			else:
				# Cross
				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_T_X_cross_start, points_T_start[1], points_T_start[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
				formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-2, N_cnt-1, RHO_STR, self.parameters.T, self.parameters.W)
				henry_E_str = henry_E_str + formatted_msg
				point_Line_List.append((henry_N_list[N_cnt-2], henry_N_list[N_cnt-1]))
				E_cnt = E_cnt + 1


				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_T_X_cross_end, points_T_start[1], points_T_start[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1

				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_R_start[0], points_R_start[1], points_R_start[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
				formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-2, N_cnt-1, RHO_STR, self.parameters.T, self.parameters.W)
				henry_E_str = henry_E_str + formatted_msg
				point_Line_List.append((henry_N_list[N_cnt-2], henry_N_list[N_cnt-1]))
				E_cnt = E_cnt + 1

				if num_N % 2 == 0:
					# VIA
					formatted_msg = 'NV%d x=%f y=%f z=%f \n' % (NV_cnt, points_T_X_cross_end, points_T_start[1], points_T_start[2] - via_L)
					henry_N_str = henry_N_str + formatted_msg
					NV_cnt = NV_cnt + 1
					formatted_msg = 'E%d NV%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, NV_cnt-1, N_cnt-2, RHO_STR, via_L, self.parameters.T)
					henry_E_str = henry_E_str + formatted_msg
					E_cnt = E_cnt + 1
					if num_N == self.parameters.N:
						# Inner Connection
						formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-3, N_cnt-8, RHO_STR, self.parameters.T, self.parameters.W)
						henry_E_str = henry_E_str + formatted_msg
						E_cnt = E_cnt + 1
						formatted_msg = 'E%d NV%d NV%d rho=%s  H=%f W=%f \n' % (E_cnt, NV_cnt-1, NV_cnt-2, RHO_STR, self.parameters.T, self.parameters.W)
						henry_E_str = henry_E_str + formatted_msg
						E_cnt = E_cnt + 1
					else:
						# Inner Connection
						formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-3, N_cnt-10, RHO_STR, self.parameters.T, self.parameters.W)
						henry_E_str = henry_E_str + formatted_msg
						E_cnt = E_cnt + 1
						formatted_msg = 'E%d NV%d NV%d rho=%s  H=%f W=%f \n' % (E_cnt, NV_cnt-1, NV_cnt-3, RHO_STR, self.parameters.T, self.parameters.W)
						henry_E_str = henry_E_str + formatted_msg
						E_cnt = E_cnt + 1
				else:
					# VIA
					formatted_msg = 'NV%d x=%f y=%f z=%f \n' % (NV_cnt, points_T_X_cross_start, points_T_start[1], points_T_start[2] - via_L)
					henry_N_str = henry_N_str + formatted_msg
					NV_cnt = NV_cnt + 1
					formatted_msg = 'E%d NV%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, NV_cnt-1, N_cnt-3, RHO_STR, via_L, self.parameters.T)
					henry_E_str = henry_E_str + formatted_msg
					E_cnt = E_cnt + 1





			if num_N == 1:
				formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-1, N_cnt-6, RHO_STR, self.parameters.T, self.parameters.W)
				henry_E_str = henry_E_str + formatted_msg
				point_Line_List.append((henry_N_list[N_cnt-1], henry_N_list[N_cnt-6]))
				E_cnt = E_cnt + 1
			elif num_N == self.parameters.N:
				formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-1, N_cnt-6, RHO_STR, self.parameters.T, self.parameters.W)
				henry_E_str = henry_E_str + formatted_msg
				point_Line_List.append((henry_N_list[N_cnt-1], henry_N_list[N_cnt-6]))
				E_cnt = E_cnt + 1
			else:
				formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-1, N_cnt-8, RHO_STR, self.parameters.T, self.parameters.W)
				henry_E_str = henry_E_str + formatted_msg
				point_Line_List.append((henry_N_list[N_cnt-1], henry_N_list[N_cnt-8]))
				E_cnt = E_cnt + 1


			# Terminate Tap
			if num_N == self.parameters.N and num_N % 2 == 0:
				# Non Bottom
				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_L_start[0], points_L_start[1] - self.parameters.GuardRing_S/2.0, points_L_start[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
				formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-6, N_cnt-1, RHO_STR, self.parameters.T, self.parameters.W)
				henry_E_str = henry_E_str + formatted_msg
				point_Line_List.append((henry_N_list[N_cnt-6], henry_N_list[N_cnt-1]))
				E_cnt = E_cnt + 1

				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_R_end[0], points_R_end[1] - self.parameters.GuardRing_S/2.0, points_R_end[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
				formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-8, N_cnt-1, RHO_STR, self.parameters.T, self.parameters.W)
				henry_E_str = henry_E_str + formatted_msg
				point_Line_List.append((henry_N_list[N_cnt-8], henry_N_list[N_cnt-1]))
				E_cnt = E_cnt + 1

				henry_Tap_str = "N" + str(N_cnt - 2) + " N" + str(N_cnt - 1)


			elif num_N == self.parameters.N and num_N % 2 == 1:
				# Non Upper
				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_L_end[0], points_L_end[1] + self.parameters.GuardRing_S/2.0, points_L_end[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
				formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-3, N_cnt-1, RHO_STR, self.parameters.T, self.parameters.W)
				henry_E_str = henry_E_str + formatted_msg
				point_Line_List.append((henry_N_list[N_cnt-3], henry_N_list[N_cnt-1]))
				E_cnt = E_cnt + 1

				formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, points_R_start[0], points_R_start[1] + self.parameters.GuardRing_S/2.0, points_R_start[2])
				henry_N_str = henry_N_str + formatted_msg
				henry_N_list.append(formatted_msg)
				N_cnt = N_cnt + 1
				formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-8, N_cnt-1, RHO_STR, self.parameters.T, self.parameters.W)
				henry_E_str = henry_E_str + formatted_msg
				point_Line_List.append((henry_N_list[N_cnt-8], henry_N_list[N_cnt-1]))
				E_cnt = E_cnt + 1

				henry_Tap_str = "N" + str(N_cnt - 2) + " N" + str(N_cnt - 1)


		formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, 0, 0, self.parameters.GuardRing_T / 2.0)
		henry_N_str = henry_N_str + formatted_msg
		henry_N_list.append(formatted_msg)
		N_cnt = N_cnt + 1
		formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, self.parameters.GuardRing_L, 0, self.parameters.GuardRing_T / 2.0)
		henry_N_str = henry_N_str + formatted_msg
		henry_N_list.append(formatted_msg)
		N_cnt = N_cnt + 1
		formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-1, N_cnt-2, RHO_STR, self.parameters.T, self.parameters.W)
		henry_E_str = henry_E_str + formatted_msg
		point_Line_List.append((henry_N_list[N_cnt-1], henry_N_list[N_cnt-2]))
		E_cnt = E_cnt + 1

		formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, self.parameters.GuardRing_L, self.parameters.GuardRing_L, self.parameters.GuardRing_T / 2.0)
		henry_N_str = henry_N_str + formatted_msg
		henry_N_list.append(formatted_msg)
		N_cnt = N_cnt + 1
		formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-1, N_cnt-2, RHO_STR, self.parameters.T, self.parameters.W)
		henry_E_str = henry_E_str + formatted_msg
		point_Line_List.append((henry_N_list[N_cnt-1], henry_N_list[N_cnt-2]))
		E_cnt = E_cnt + 1

		formatted_msg = 'N%d x=%f y=%f z=%f \n' % (N_cnt, 0, self.parameters.GuardRing_L, self.parameters.GuardRing_T / 2.0)
		henry_N_str = henry_N_str + formatted_msg
		henry_N_list.append(formatted_msg)
		N_cnt = N_cnt + 1
		formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-1, N_cnt-2, RHO_STR, self.parameters.T, self.parameters.W)
		henry_E_str = henry_E_str + formatted_msg
		point_Line_List.append((henry_N_list[N_cnt-1], henry_N_list[N_cnt-2]))
		E_cnt = E_cnt + 1

		formatted_msg = 'E%d N%d N%d rho=%s  H=%f W=%f \n' % (E_cnt, N_cnt-1, N_cnt-4, RHO_STR, self.parameters.T, self.parameters.W)
		henry_E_str = henry_E_str + formatted_msg
		point_Line_List.append((henry_N_list[N_cnt-1], henry_N_list[N_cnt-4]))
		E_cnt = E_cnt + 1

		print (henry_N_str)
		print (henry_E_str)
		print (henry_Tap_str)
		return ((henry_N_str + "\n" + henry_E_str), henry_Tap_str, point_Line_List)





if __name__ == '__main__':

	R = 20.0		# InnerR
	S = 2.0			# Wire2Wire Space
	W = 2.0			# Wire Width
	N = 4			# Number of rolls
	T = METAL_THICKNESS	# um Thickness

	GuardRing_S = 20.0	# Guard Ring to Inductor Space 
	GuardRing_W = 2.0	# Guard Ring Wire Width

#	generator = InductorGenerator(InductorShapeType.symmetry, R, S, W, N, T, GuardRing_S, GuardRing_W)
	generator = InductorGenerator(InductorShapeType.spiral, R, S, W, N, T, GuardRing_S, GuardRing_W)
	generator.generateInductor4henry()
	generator.generateInductor4gds()

