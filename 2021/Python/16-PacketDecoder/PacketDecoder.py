#!/usr/bin/env python3

# Packet Decoder
# https://adventofcode.com/2021/day/16

from functools import reduce
from operator import mul


class Bitstream:

	mask = [0x80, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc, 0xfe, 0xff]

	def __init__(self, hex):
		self.bytes = bytes.fromhex(input)
		self.bits = 8
		self.index = 0
		self.current = self.bytes[self.index] if self.index < len(self.bytes) else 0

	def next(self, bits):
		result = 0
		while bits > 0:
			bits_to_read = min(bits, self.bits, 8)
			value = self.current & Bitstream.mask[bits_to_read - 1]
			self.current <<= bits_to_read

			value >>= (8 - bits_to_read)
			result <<= bits_to_read
			result |= value

			bits -= bits_to_read
			self.bits -= bits_to_read
			if self.bits == 0:
				self.move_to_next_byte()
		return result

	def skip(self):
		if bits != 0:
			self.move_to_next_byte()

	def move_to_next_byte(self):
		self.bits = 8
		self.index += 1
		self.current = self.bytes[self.index] if self.index < len(self.bytes) else 0

	def __repr__(self):
		return f"{hex(self.current)} + " + f"{self.bytes[self.index+1:]}"


class Packets:

	op_sum = 0
	op_prod = 1
	op_min = 2
	op_max = 3
	op_literal = 4
	op_gt = 5
	op_lt = 6
	op_eq = 7

	def __init__(self, bitstream):
		self.bitstream = bitstream

	def next_packet(self):
		version, type_id = self.get_header()
		if type_id == Packets.op_literal:
			literal, bit_length = self.get_literal()
			return (version, type_id, literal), bit_length + 6
		else:
			subpackets, bit_length = self.get_subpackets()
			return (version, type_id, subpackets), bit_length + 6

	def get_header(self):
		version = self.bitstream.next(3)
		type_id = self.bitstream.next(3)
		return version, type_id

	def get_literal(self):
		literal = 0
		bit_length = 0
		while True:
			bit_length += 5
			next_nibble = self.bitstream.next(5)
			literal <<= 4
			literal |= (next_nibble & 0xf)
			if next_nibble & 0x10 == 0:
				break
		return literal, bit_length

	def get_subpackets(self):
		subpackets = []
		bit_length = 1
		length_type = self.bitstream.next(1)
		if length_type == 0:
			length = self.bitstream.next(15)
			bit_length += 15
			while length > 0:
				packet, packet_bits = self.next_packet()
				subpackets.append(packet)
				bit_length += packet_bits
				length -= packet_bits
		else:
			num_packets = self.bitstream.next(11)
			bit_length += 11
			while num_packets > 0:
				packet, packet_bits = self.next_packet()
				subpackets.append(packet)
				bit_length += packet_bits
				num_packets -= 1
		return subpackets, bit_length


def read_file(name):
	file = open(name)
	return [line.strip() for line in file.readlines()]


def sum_of_versions(packet):
	version_sum = packet[0]
	if packet[1] == Packets.op_literal:
		return version_sum

	for subpacket in packet[2]:
		version_sum += sum_of_versions(subpacket)
	return version_sum


def operate(packet):
	_, operation, value = packet
	if operation == Packets.op_literal:
		return value

	subpacket_values = [operate(packet) for packet in value]
	if operation == Packets.op_sum:
		return sum(subpacket_values)
	if operation == Packets.op_prod:
		return reduce(mul, subpacket_values)
	if operation == Packets.op_min:
		return min(subpacket_values)
	if operation == Packets.op_max:
		return max(subpacket_values)

	assert (len(subpacket_values) == 2)
	if operation == Packets.op_gt:
		return 1 if subpacket_values[0] > subpacket_values[1] else 0
	if operation == Packets.op_lt:
		return 1 if subpacket_values[0] < subpacket_values[1] else 0
	if operation == Packets.op_eq:
		return 1 if subpacket_values[0] == subpacket_values[1] else 0

	# invalid operation
	return None


input = read_file("input.txt")[0]

bits = Bitstream(input)
packets = Packets(bits)
packet, _ = packets.next_packet()
version_sums = sum_of_versions(packet)
print(f"Part 1: {version_sums}")

bits = Bitstream(input)
packets = Packets(bits)
packet, _ = packets.next_packet()
result = operate(packet)
print(f"Part 2: {result}")

