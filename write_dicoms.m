function write_dicoms(image_file, header_file, save_path)
%% Write a stack of dicom files for the current reconstruction
% Arguments:
%   image_file: path to the Nifti image (3D) to be written to file. Ensure
%       CT images are in HU before saving.
%   header_file: path to a JSON file containing the required DICOM fields.
%   save_path: path to the directory in which the DICOM files will be
%       written.

%{
%%%%%%%%%%%%%%        DICOM Fields        %%%%%%%%%%%%%%

The following fields are used in this program. To use this function outside
the GUI interface, write the following fields into a structre and save that
structure as a JSON file.

% Constant parameters
dicom_header.FileModDate= datestr(t, 'YYYYmmdd');
dicom_header.FileSize= size(X, 1) * size(X, 2) * (0.524 / 512^2);
dicom_header.Format= 'DICOM';
dicom_header.FormatVersion= 3;
dicom_header.ColorType= 'grayscale';
dicom_header.FileMetaInformationGroupLength= 196;
dicom_header.FileMetaInformationVersion= uint8([0 1]');
dicom_header.MediaStorageSOPClassUID= dicomuid;
dicom_header.MediaStorageSOPInstanceUID= dicomuid;
dicom_header.TransferSyntaxUID= '1.2.840.10008.1.2.1';
dicom_header.ImplementationClassUID= dicomuid;
dicom_header.ImplementationVersionName= 'CIVM_microCT_v1';
dicom_header.SOPClassUID= dicomuid;
dicom_header.SOPInstanceUID= dicomuid;
dicom_header.ContentTime= num2str(datenum(t));
dicom_header.AccessionNumber=[num2str(t.Year) num2str(t.Month,'%10.2d') num2str(t.Day, '%10.2d')]; %num2str(datenum(datetime)) ; %'2819497684894127';
dicom_header.PatientSpeciesCodeSequence = 1;
dicom_header.ClinicalTrialSponsorName= '';
dicom_header.ClinicalTrialSubjectReadingID= '';
dicom_header.PatientIdentityRemoved= 'No';
dicom_header.Width= size(X, 1);
dicom_header.Height= size(X, 2);
dicom_header.BitDepth= 12;
dicom_header.StudyInstanceUID= dicomuid;
dicom_header.SeriesInstanceUID= dicomuid;
dicom_header.ImageOrientationPatient= [1     0     0     0     1     0]';
dicom_header.FrameOfReferenceUID= dicomuid;
dicom_header.PositionReferenceIndicator= '';
dicom_header.SliceLocation= 0;
dicom_header.SamplesPerPixel= 1;
dicom_header.PhotometricInterpretation= 'MONOCHROME2';
dicom_header.BitsAllocated= 16;
dicom_header.BitsStored= 12;
dicom_header.HighBit= 11;
dicom_header.PixelRepresentation= 1;
dicom_header.WindowCenter= 200;
dicom_header.WindowWidth= 2000;
dicom_header.PixelDimensions = [1 1];
dicom_header.Rows= size(X, 1);
dicom_header.Columns= size(X, 2);
dicom_header.ReconstructionDiameter= max([size(X, 1), size(X, 2)]);
dicom_header.StorageMediaFileSetUID= dicomuid;
dicom_header.InstanceNumber= 1;
dicom_header.ImagePositionPatient= [ 0 0 0 ]';
dicom_header.RescaleIntercept = -1200;
dicom_header.RescaleSlope = 1;

% Acquisition settings
dicom_header.Modality= 'Micro-CT';
dicom_header.Manufacturer= 'Duke CIVM Scanner';
dicom_header.StationName= 'BlackBeauty5';
dicom_header.ImageType= 'ORIGINAL\PRIMARY\AXIAL\CT';
dicom_header.ManufacturerModelName = 'CIVM-Dexela';
dicom_header.SoftwareVersion = 'LabVIEW';
dicom_header.DistanceSourceToDetector = dsd;
dicom_header.DistanceSourceToPatient = dso;
dicom_header.GantryDetectorTilt= 0;
dicom_header.TableHeight= 0;
dicom_header.RotationDirection= 'CW';

dicom_header.ExposureTime = str2double(dicom_header.ExposureTime);
dicom_header.XrayTubeCurrent = str2double(dicom_header.XrayTubeCurrent);
dicom_header.Exposure = str2double(dicom_header.Exposure);
dicom_header.FilterType= '0';
dicom_header.GeneratorPower = str2double(dicom_header.GeneratorPower);
dicom_header.FocalSpot = str2double(dicom_header.FocalSpot);
dicom_header.DateOfLastCalibration= '';
dicom_header.TimeOfLastCalibration= '';
dicom_header.KVP= KVP;
dicom_header.PixelSpacing= [CTX.px CTX.py]';
dicom_header.SliceThickness= CTX.pz;


% Subject settings
dicom_header.ClinicalTrialProtocolID= 'U24';
dicom_header.ClinicalTrialProtocolName= CTX.code;
dicom_header.ProtocolName= char(dicom_header.ProtocolName);
dicom_header.StudyDescription= char(dicom_header.StudyDescription);
dicom_header.SeriesDescription= char(dicom_header.SeriesDescription);
dicom_header.StudyID= CTX.code;
dicom_header.AcquisitionNumber= CTX.set;
dicom_header.PatientPosition= 'HFS';
dicom_header.ProcedureDescription = char(dicom_header.ProcedureDescription);

dicom_header.PatientSpecies = char(dicom_header.PatientSpecies);
dicom_header.StudyDate = [YYYY MM DD];
dicom_header.SeriesDate = [YYYY MM DD];
dicom_header.AcquisitionDate = [YYYY MM DD];
dicom_header.ContentDate = [YYYY MM DD];
dicom_header.StudyTime= datestr(t, 'hhmmss');
dicom_header.SeriesTime= datestr(t, 'hhmmss');
dicom_header.AcquisitionTime= datestr(t, 'hhmmss');
dicom_header.PatientID = CTX.specid;
dicom_header.PatientBirthDate = char(dicom_header.DOB);
dicom_header.PatientSex = char(dicom_header.PatientSex);
dicom_header.PatientWeight = str2double(dicom_header.PatientWeight);
dicom_header.BodyPartExamined = char(dicom_header.BodyPart);

%}

%% Set up function paths

update_paths;

%% Unpack the header information

dicom_header = loadjson(header_file);

fprintf('Processing DICOM header from file:\n\t%s\n', fullfile(header_file));

%% Load image

X = load_nii(image_file);
X = X.img;

%% Check that X has been converted to HU

% Find maxima in the histogram - can be buggy
ahu = (max(X(:)) - min(X(:))) > 1000;

if ~ahu
    
    warning('ERROR: DICOM conversion requires volume in HU')
    warning('Aborting conversion to DICOM')
    
    return
    
end

%% Prepare header

% Study date
study_date = datetime([dicom_header.StudyDate.Year,...
    dicom_header.StudyDate.Month,...
    dicom_header.StudyDate.Day]);
t = datetime(dicom_header.StudyTime, 'InputFormat', 'hhmmss');
   

%% Update Header values

% Constant parameters
dicom_header.FileModDate= datestr(t, 'YYYYmmdd');
dicom_header.FileSize= size(X, 1) * size(X, 2) * (0.524 / 512^2);
dicom_header.Format= 'DICOM';
dicom_header.FormatVersion= 3;
dicom_header.ColorType= 'grayscale';
dicom_header.FileMetaInformationGroupLength= 196;
dicom_header.FileMetaInformationVersion= uint8([0 1]');
dicom_header.MediaStorageSOPClassUID= dicomuid;
dicom_header.MediaStorageSOPInstanceUID= dicomuid;
dicom_header.TransferSyntaxUID= '1.2.840.10008.1.2.1';
dicom_header.ImplementationClassUID= dicomuid;
dicom_header.ImplementationVersionName= 'CIVM_microCT_v1';
dicom_header.SOPClassUID= dicomuid;
dicom_header.SOPInstanceUID= dicomuid;
dicom_header.ContentTime= num2str(datenum(t));
dicom_header.PatientSpeciesCodeSequence = 1;
dicom_header.ClinicalTrialSponsorName= '';
dicom_header.ClinicalTrialSubjectReadingID= '';
dicom_header.PatientIdentityRemoved= 'No';
dicom_header.Width= size(X, 1);
dicom_header.Height= size(X, 2);
dicom_header.BitDepth= 12;
dicom_header.StudyInstanceUID= dicomuid;
dicom_header.SeriesInstanceUID= dicomuid;
dicom_header.ImageOrientationPatient= [1     0     0     0     1     0]';
dicom_header.FrameOfReferenceUID= dicomuid;
dicom_header.PositionReferenceIndicator= '';
dicom_header.SliceLocation= 0;
dicom_header.SamplesPerPixel= 1;
dicom_header.PhotometricInterpretation= 'MONOCHROME2';
dicom_header.BitsAllocated= 16;
dicom_header.BitsStored= 12;
dicom_header.HighBit= 11;
dicom_header.PixelRepresentation= 1;
dicom_header.WindowCenter= 200;
dicom_header.WindowWidth= 2000;
dicom_header.PixelDimensions = [1 1];
dicom_header.Rows= size(X, 1);
dicom_header.Columns= size(X, 2);
dicom_header.ReconstructionDiameter= max([size(X, 1), size(X, 2)]);
dicom_header.StorageMediaFileSetUID= dicomuid;
dicom_header.InstanceNumber= 1;
dicom_header.ImagePositionPatient= [ 0 0 0 ]';
dicom_header.RescaleIntercept = -1200;
dicom_header.RescaleSlope = 1;

% Acquisition settings
% Convert numeric entries to double
dicom_header.ExposureTime = str2double(dicom_header.ExposureTime);
dicom_header.XrayTubeCurrent = str2double(dicom_header.XrayTubeCurrent);
dicom_header.Exposure = str2double(dicom_header.Exposure);
dicom_header.GeneratorPower = str2double(dicom_header.GeneratorPower);
dicom_header.FocalSpot = str2double(dicom_header.FocalSpot);
dicom_header.PixelSpacing= [str2double(dicom_header.PixelSpacing),...
                            str2double(dicom_header.PixelSpacing)]';
dicom_header.SliceThickness = str2double(dicom_header.SliceThickness);

dicom_header.StudyDate = datestr(study_date, 'YYYYmmdd');
dicom_header.SeriesDate = datestr(study_date, 'YYYYmmdd');
dicom_header.AcquisitionDate = datestr(study_date, 'YYYYmmdd');
dicom_header.AccessionNumber = datestr(study_date, 'YYYYmmdd');
dicom_header.ContentDate = datestr(study_date, 'YYYYmmdd');
dicom_header.StudyTime= datestr(t, 'hhmmss');
dicom_header.SeriesTime= datestr(t, 'hhmmss');
dicom_header.AcquisitionTime= datestr(t, 'hhmmss');





%% Convert image volume to 16 bit

if ~exist(save_path, 'dir'), mkdir(save_path); end

% Convert volume to 16 bit
% Rescale images
X = uint16(( X - dicom_header.RescaleIntercept ) / dicom_header.RescaleSlope );


%% Write dicom

fprintf('Writing dicoms\n\tfrom: %s\n', image_file);
fprintf('\tTo: %s\n', save_path);
slices = size(X, 3);
str_out = sprintf('1 of %d\t', slices);
fprintf('\t\tWriting slice:\t%s', str_out)
for z = 1:slices
    
    % Show output
    if mod(z,20) == 0
        fprintf(repmat('\b', [1, length(str_out)]))
        str_out = sprintf('%d of %d\t', z, slices);
        fprintf(str_out)
    end
    
    % Create file name
    sname = sprintf('%s\\%s.%04d.dcm', save_path, dicom_header.ProtocolName, z-1);
    
    % Get and write slice to file
    temp = X(:,:,z);
    dicomwrite(temp, sname, dicom_header, 'ObjectType','CT Image Storage');
    
    % Update location fields
    dicom_header.InstanceNumber = dicom_header.InstanceNumber + 1;
    dicom_header.SliceLocation = dicom_header.SliceLocation - dicom_header.SliceThickness;
    dicom_header.ImagePositionPatient = [ 0 0 dicom_header.SliceLocation];
    
end

fprintf('\n\t\tDone!\n\n')


end

