function save_header(dicom_header, file_name)
%save_header Save GUI data as a json file
%   Takes a stucture with DICOM header fields and writes them to a JSON
%   file for storage.

% Write code as a json
savejson('', dicom_header, file_name);

end

