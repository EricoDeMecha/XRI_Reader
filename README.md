# XRI Reader 
## Background

Standard image file formats exist for general image files (JPEG, PNG, TIFF,etc.) as well as specialist application areas, such as medical imaging(DICOM). Despite these standard formats, data from medical imaging devices often comes in non-standard formats developed by the equipment manufacturer. These file formats arise as none of the standard formats are suitable for a number of reasons, including limited pixel data formats (e.g. JPEG), or formats such as DICOM are overly complex for the task in hand. In such cases you will be required to write custom software to read and/or convert these files into a format MATLAB can understand. The aim of this project is to develop software that will read images in one such file is called the “XRI” format. 

## Full details of XRI Format

### The XRI File Format

The xri file format is designed to store x-ray images. The XRI file format can be used to store a sequence of 2D greyscale images in a number of pixel datatypes. Each 2D image is referred to as a frame. The format consists of a header, containing information about the pixel format in the file, and then the pixel data itself. There is no gap between the header and pixel data.

### File Byte Order

The file format is a binary format, i.e. not a text based format. It is therefore necessary to take account of the order of bytes within fields when reading the header and pixel data in the file. Different types of computer use different orders of bytes for their multi-byte data types. There are two main classes of byte order: big endian and little endian. Some binary file formats specify that their contents will always be big or little endian, but the XRI format allows both types. This allows for greater efficiency when reading and writing files on the same computer architecture. The big endian version and a little endian versions of the XRI file format can be discriminated by the file’s “magic number” (see below). When reading and writing XRI files a program must convert header and pixel data’s byte order if it differs from that used on the local machine.

### The Header

The header comprises two parts:
- A 128 byte header information block (HIB), which is always present in every file
- An optional information field of variable length.

### The Header Information Block

The header information block contains information on the file byte order, size of an image frame, number of frames, length of the comment field and other information. The HIB is always 128 bytes is size, although not all of it is used. In fact only 36 bytes are used; the rest are reserved for possible future extensions of the format. The HIB is divided into the fields described in the table below:

#### HIB Components

[!HIB Components](https://github.com/EricoDeMecha/XRI_Reader/blob/main/imgs/HIBComponents.png)

The information field follows the HIB. If i_len was zero, then no extra information is present, and the pixel data follows the HIB. If i_len is greater than zero then i_len specifies the number of ASCII characters that follow the HIB. This field allows infor-
mation to be stored about the image file in a string.

### Pixel Data

Pixels are stored in one of three formats as specified by the s_type field in the HIB. The byte order of each pixel for types 0 and 1 is as used in the HIB. Pixels are ordered in the following order row, column, frame. In other words the first pixel in the file is
the top left of the first frame. The pixel at row 1, column 2 in the first frame follows. For a file with M rows, N columns and F frames, with (c, r, f) representing pixel at row r, column c, and frame f, the pixels in the file are ordered thus:

#### Pixel Storage

Pixel values in the file are arranged in the following order:
```bash
(1,1,1) (2,1,1), ..... (N,1,1)
(1,2,1) (2,2,1), ....  (N,2,1)
(1,M,1), ....          (N,M,1)
(1,1,2), (2,1,2), .... (N,1,2)
....
(1,M,F), ....           (N,M,F)
```
No data are stored at the end of the pixel data.


## Test

A number of XRI files are available under the test folder. The examples images
are:

- cine_frame.xri is a single frame from a digital cardiac x-ray
sequence.
- cine_run2.xri is a number of images from the same sequence.
- fluoroscopy.xri is a low x-ray dose fluoroscopy image sequence.
- ramp.xri is a 256 x 256 image with all pixels in row 1 having a value
of 255, all pixels in row 2 having a value of 254, all pixels in row 3
having a value of 253, and so on until row 256 where all pixels have
a value of 0.

```bash
>>> run % calls the main reader

```