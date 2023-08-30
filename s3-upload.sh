#!/bin/bash

# Set your S3 bucket name
s3_bucket_name="exchange-data-raw-files"

# Set the folder path
folder_path="/home/ec2-user/exchange_data/raw_data"

# Calculate today's date in the format of your file names (e.g., '20230826')
today_date=$(date +%Y%m%d)

# List files in the folder
for file_path in $folder_path/*; do

    # Check if it's a file
    if [ -f "$file_path" ]; then
        # Extract the file's modification date from the filename (assuming the format is consistent)
        file_date=$(basename "$file_path" | cut -d'_' -f2 | cut -d'.' -f1)

        # Compare the file's date with today's date
        if [ "$file_date" -lt "$today_date" ]; then
            # Print a message indicating which file is being processed
            echo "Processing file: $file_path"

            # Compress the file with gzip -9
            sudo gzip -9 "$file_path"

            # Upload the compressed file to S3
            if aws s3 cp "${file_path}.gz" "s3://${s3_bucket_name}/"; then
                # Successful upload, now confirm and then delete the file from the local EBS volume
                if aws s3 ls "s3://${s3_bucket_name}/${file_name}.gz"; then
                    sudo rm "${file_path}.gz"
                    echo "Uploaded and deleted: $file_name"
                else
                    echo "Upload confirmation failed for: $file_name"
                fi
            else
                # Upload failed, leave the file on the local EBS volume
                echo "Upload failed for: $file_name"
            fi
        fi
    fi
done

echo "Script finished at: $(date)"