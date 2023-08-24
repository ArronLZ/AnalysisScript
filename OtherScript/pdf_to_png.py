import os
import sys
from PyPDF2 import PdfReader
from pdf2image import convert_from_path


# Check if the correct number of arguments is provided
if len(sys.argv) != 3 and len(sys.argv) != 4:
    print("Usage: python pdf2png_converter.py <pdf_directory> <png_output_directory> [dpi]")
    sys.exit(1)

pdf_folder = sys.argv[1]
png_output_folder = sys.argv[2]

# Check if dpi argument is provided, otherwise use default value 400
if len(sys.argv) == 4:
    dpi = int(sys.argv[3])
else:
    dpi = 400
    

# Check if the PDF directory exists and contains PDF files
pdf_files = [file for file in os.listdir(pdf_folder) if file.lower().endswith(".pdf")]
if not os.path.exists(pdf_folder) or len(pdf_files) == 0:
    print("Error: PDF directory does not exist or does not contain PDF files.")
    sys.exit(1)

# Create the PNG output directory if it doesn't exist
if not os.path.exists(png_output_folder):
    os.makedirs(png_output_folder)


# Loop through each PDF file
for pdf_file in pdf_files:
    pdf_path = os.path.join(pdf_folder, pdf_file)
    pdf = PdfReader(pdf_path)
    num_pages = len(pdf.pages)

    for page in range(num_pages):
        png_output_file = os.path.join(png_output_folder, f"{os.path.splitext(pdf_file)[0]}_page{page + 1}.png")
        images = convert_from_path(pdf_path, first_page=page + 1, last_page=page + 1, dpi = dpi)
        images[0].save(png_output_file, "PNG")
        print(f"Converted page {page + 1} of {pdf_file} to {png_output_file}")

print("\n PDF to PNG conversion complete!")
