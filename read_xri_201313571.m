function [img, cmt] = read_xri_201313571(filename, frames,region)
%function: reads xri image with custom HIB
%params:  filename   - xri image file
%         frames     - number of frames to be obtained
%         region     - region of the frame to obtain
% returns: img       - array of image values
%          cmt       - comment from optional block.

    if nargin < 1
        fprintf('Usage: read_xri_54321 filename frames region\n');
        return;
    end
    if ~isfile(filename) % check if the file exist
        fprintf('\n %s do not exist in the current folder\n ', filename);
        return;
    end
    fid = fopen(filename, 'rb');
    if nargin == 1
        % return all pixels plus the comment
        [img,cmt] = seekFile(fid); % I suppose you meant this
        return;
    end
    if nargin == 2
        if isscalar(frames) == 1
            temp_frames = [1,frames];
            [img,cmt] = seekFile(fid,temp_frames);
        else
            if isempty(frames)
                % return all the pixels plut the comment
                [img,cmt] = seekFile(fid);
                return;
            end
            if length(frames) == 2
                if frames(1) > frames(end)
                    fprintf('\n[Error] Inversed range \n');
                    return;
                end
                [img,cmt] = seekFile(fid,frames);
            end 
        end
    end
    
    if nargin == 3
         if isscalar(frames) == 1
            temp_frames = [1,frames];% make the frames an array
            [w_img,cmt, R,C] = seekFile(fid,temp_frames);
            img = processFrame(w_img, R, C, region);
        else
            if isempty(frames)
                % return all the pixels plut the comment
                [w_img,cmt, R,C] = seekFile(fid);
                img = processFrame(w_img, R, C, region);
                return;
            end
            if length(frames) == 2
                if frames(1) > frames(end)
                    fprintf('\n[Error] Inversed range \n');
                    return;
                end
                [w_img,cmt,R,C] = seekFile(fid,frames);
                img = processFrame(w_img, R, C, region);
            end 
        end
    end
 
    fclose(fid);
end

function img = processFrame(w_img, R , C,region)
% function : process the frames obtained for the regions
% params:  w_img - image values array
%          R     - Number of rows in the image
%          C     - Number of columns in the image
%          region - region of the frame to be extracted
% return: img - image values array       

    if isscalar(region) == 1
        img = extractRegion(w_img, R, C, region);
    else
        if length(region) == 2
            img = extractRegion(w_img, R, C, region(1), region(2));
        else
            if length(region) == 4
               img = extractRegion(w_img, R, C, region(1), region(2), region(3),region(4));
            else
               fprintf('\n[Error] Inaccurate argument list\n');
            end
        end
    end
end


function [img,cmt, rows, cols] = seekFile(fid, f_lim)
%function:  helper function to seek read the contents of the file using HIB
% param: fid - file handler
%       f_lim - number of frames to be extracted
% return: img - image values array
%           cmt - Comments from the OIB
%           rows - number of rows in the image
%           cols - number of cols in the image
    if nargin == 1
        f_lim = zeros(1,2);
    end
    swap = false; % swapbytes flag
    [l_type, max_size, l_endian]= computer; % get  the endianess of the local machine
    fseek(fid,0,'bof');
    % endian: read bytes 1-4
    endian = fread(fid,4,'*char');
    if endian(3) ~=  l_endian
        swap = true;  
    end
    fprintf('Endian: %s\n', endian);
    % frame columns:  bytes 5-8
    f_cols = fread(fid,4,'*uint8');
    % frame columns: bytes 9-12
    f_rows = fread(fid,4,'*uint8');
    % nframes: bytes 13-16
    nframes = fread(fid,4,'*uint8');
    % s_type: bytes 17-20
    s_type = fread(fid,4,'*uint8');
    % i_len: bytes  21-24
    i_len = fread(fid,4,'*uint8');
    % check if the swap flag is true
    if swap
        f_cols = swapbytes(f_cols);
        f_rows = swapbytes(f_rows);
        nframes = swapbytes(nframes);
        s_type = swapbytes(s_type);
        i_len = swapbytes(i_len);
    end
    f_cols = findNoneZero(f_cols); f_rows = findNoneZero(f_rows);
    nframes= findNoneZero(nframes); s_type= findNoneZero(s_type);
    i_len = findNoneZero(i_len);
    fprintf('f_cols: %d \n', f_cols);
    fprintf('f_rows: %d \n', f_rows);
    fprintf('nframes: %d \n', nframes);
    fprintf('s_type: %d \n', s_type);
    fprintf('i_len: %d \n', i_len);
    
    plain_data_type = '*uint8';
    if s_type(end) == 0
        plain_data_type = '*double';
    end
    if s_type(end) == 1
        plain_data_type = '*int16';
    end
    if s_type(end) == 2
       plain_data_type = '*uint8';
    end
    fseek(fid,128,'bof'); % skip reserved memory
     % check for the optional information field
    if i_len ~= 0
        cmt =fread(fid,i_len, '*char');
        fseek(fid,(128 + i_len), 'bof');
    else
        cmt = "";
    end
    if (f_lim(end) > 0) && (f_lim(end) < nframes)
        for i = f_lim(1):f_lim(end)
            img(:,:,i) = fread(fid,[f_rows, f_cols],plain_data_type);
        end
    else
        for i = 1:nframes
            img(:,:,i) = fread(fid,[f_rows, f_cols],plain_data_type);
        end
    end
    % return the number of columns and rows of the
    % image
    rows = f_rows;
    cols = f_cols;
end
function proc = findNoneZero(raw)
% function: This is a helper function to find a non-zero
%           value in the blocks of array obtained from the
%           header block.
% Param: raw - raw block bytes array.
% return: proc - Indentified integer in the block
%               array
    if isempty(raw)
        fprintf('\n Array is empty \n');
        return;
    end
    for i = 1:length(raw)
        if raw(i) ~= 0
            proc = raw(i); 
            return;
        end
    end
    proc = 0;
end

function p_img = extractRegion(img, R, C, g1, g2,g3,g4)
% function: Extract the region of the image
%           specified by the coordinates
% Params: img - image values array
%         R - number of rows in a frame
%           C - number of columns in a frame
%         g1,g2,g3.g4 coordinates of the region
% Return: p_img - image values of the extracted
%                 region.
    center_r = ceil(R/2);
    center_c = ceil(C/2);
    if nargin == 4
        pos_r1 = (center_r - ceil(g1/2));
        pos_c1 = (center_c - ceil(g1/2));
        
        limChecker(R, C, pos_r1, pos_c1);
        
        pos_r4 = (center_r + ceil(g1/2));
        pos_c4 = (center_c + ceil(g1/2));
         
        limChecker(R, C, pos_r4, pos_c4);
        
        % use an extractor
        pos = [pos_r1,pos_c1,pos_r4,pos_c4];
        p_img  = extractor(img, pos);
        return;
    end
    
    if nargin == 5
        pos_r1 = (center_r - ceil(g1/2));
        pos_c1 = (center_c - ceil(g2/2));
         
        limChecker(R, C, pos_r1, pos_c1);
        
        pos_r4 = (center_r + ceil(g1/2));
        pos_c4 = (center_c + ceil(g2/2));
         
        limChecker(R, C, pos_r4, pos_c4);
        
        % use an extractor
        pos = [pos_r1,pos_c1,pos_r4,pos_c4];
        p_img  = extractor(img, pos);
        return;
    end
    
    if nargin == 7
        pos_r1 = g1;
        pos_c1 = g3;
         
        limChecker(R, C, pos_r1, pos_c1);
        
        pos_r4 = g2;
        pos_c4 = g4;
         
        limChecker(R, C, pos_r4, pos_c4);
        
        % use  an extractor
        pos = [pos_r1,pos_c1,pos_r4,pos_c4];
        p_img  = extractor(img, pos);
        return;
    end
    fprintf('\n[Error] Inaccurate  argument list\n');
end

function limChecker(R,C,r,c)
% function: Checks whether the coordinates of the region are out
%            of the image frame
% Params: R - Number of rows in the image
%         C - Number of cols in the image
%         r - Number of rows of the region
%         c - Number of cols of the region
    if r < 1 || r > R
        fprintf('\n[Error] Region extends outside the frame\n');
        return;% quit the whole program
    end
    if c < 1 || c > C
        fprintf('\n[Error] Region extends outside the frame\n');
        return;% quit the whole program
    end
end

function extr = extractor(img,region)
% function: Extracts the required region

    % Initializing before use
    for q = 1: ndims(img)
        frame = img(:,:,q);
        extr(:,:,q) = frame(region(1):region(3),region(2):region(4));
    end
end
