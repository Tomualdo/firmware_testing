import sys

class FirmwarePart:
    def __init__(self,name,offset,size):
        self.name = name
        self.offset = offset
        self.size = size

firmware_parts = [
        FirmwarePart("uimage_header",0x0,0x40),
        FirmwarePart("uimage_kernel",0x40,0x1F000),
        FirmwarePart("squashfs1",0x1F0040,0x3D0000),
	FirmwarePart("squashfs2",0x5C0040,12058752-0x5c0040)
]

if sys.argv[1] == "unpack":
        # open bin file as 2nd arg
	f = open(sys.argv[2],'rb')
        # loop over parts with name offset and size
	for part in firmware_parts:
                # create outfile
		outfile = open(part.name,'wb')
                # shift to position pointer in bin file
		f.seek(part.offset,0)
                # read related size of bin file
		data = f.read(part.size)
                # save file
		outfile.write(data)
		outfile.close()
		print("wrote {} - {} bytes".format(part.name,hex(len(data))))
else:
    print ("unpack req !")

	


"""
DECIMAL       HEXADECIMAL     DESCRIPTION
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
0             0x0             uImage header, header size: 64 bytes, header CRC: 0xD166ED4C, created: 2020-12-15 23:36:17, image size: 9830400 bytes, Data Address: 0x0, Entry Point: 0x0, data CRC: 0x9D92C883,
                              OS: Linux, CPU: MIPS, image type: Firmware Image, compression type: none, image name: "jz_fw"
64            0x40            uImage header, header size: 64 bytes, header CRC: 0x77F7FCF0, created: 2020-12-15 20:24:54, image size: 1801102 bytes, Data Address: 0x80010000, Entry Point: 0x803E17B0, data CRC:
                              0x76AA2CB5, OS: Linux, CPU: MIPS, image type: OS Kernel Image, compression type: lzma, image name: "Linux-3.10.14__isvp_swan_1.0__"
128           0x80            LZMA compressed data, properties: 0x5D, dictionary size: 33554432 bytes, uncompressed size: -1 bytes
2031680       0x1F0040        Squashfs filesystem, little endian, version 4.0, compression:xz, size: 3752704 bytes, 371 inodes, blocksize: 131072 bytes, created: 2020-12-15 23:36:14
6029376       0x5C0040        Squashfs filesystem, little endian, version 4.0, compression:xz, size: 3800410 bytes, 87 inodes, blocksize: 131072 bytes, created: 2020-12-15 23:36:17
"""
