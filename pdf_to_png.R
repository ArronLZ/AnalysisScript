# Check if required arguments are provided
if (length(commandArgs(trailingOnly = TRUE)) != 2) {
  cat("Usage: Rscript pdf2png_converter.R <pdf_directory> <png_output_directory>\n")
  quit(status = 1)
}

# Get the arguments
pdf_folder <- commandArgs(trailingOnly = TRUE)[1]
png_output_folder <- commandArgs(trailingOnly = TRUE)[2]

# Check if the PDF directory exists and contains PDF files
if (!file.exists(pdf_folder) || length(list.files(pdf_folder, pattern = ".pdf$", full.names = TRUE)) == 0) {
  cat("Error: PDF directory does not exist or does not contain PDF files.\n")
  quit(status = 1)
}

# Create the PNG output directory if it doesn't exist
if (!dir.exists(png_output_folder)) {
  dir.create(png_output_folder)
}

# Load the pdftools package
library(pdftools)

# Get PDF files list
pdf_files <- list.files(pdf_folder, pattern = ".pdf$", full.names = TRUE)

# Loop through each PDF file
for (pdf_file in pdf_files) {
  pdf <- pdftools::pdf_info(pdf_file)
  num_pages <- pdf$pages

  for (page in 1:num_pages) {
    png_output_file <- file.path(png_output_folder, paste0(tools::file_path_sans_ext(basename(pdf_file)), "_page", page, ".png"))
    pdftools::pdf_convert(pdf_file, format = "png", pages = page, dpi = 400, filenames = png_output_file)
    cat("Converted page", page, "of", pdf_file, "to", png_output_file, "\n")
  }
}

cat("\nPDF to PNG conversion complete!\n")
