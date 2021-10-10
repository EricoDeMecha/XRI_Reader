function run()
    files = dir('./test/*.xri'); % count the number of file in the direcotry
    file_path = fullfile(files(1).folder, files(1).name); % first file 
    for i = 1:length(files)
        fprintf('Processing file %s\n', file_path);
        file_path = fullfile(files(i).folder, files(i).name);
        % 1- with filename only
        %[img,cmt]= read_xri_201313571(file_path);
        %disp(img); disp(cmt);
        % 2- with frames specified
        %[img,cmt] = read_xri_201313571(file_path,2);
        %disp(img); disp(cmt);
        % 3- with frames  in an empty array
        %[img,cmt]= read_xri_201313571(file_path,[]);
        %disp(img); disp(cmt);
        % 4. with frames in an array
        %[img,cmt]= read_xri_201313571(file_path,[2 3]);
        %disp(img); disp(cmt);
        % 5. with region
        %[img,cmt]= read_xri_201313571(file_path, 1,50);
        %disp(img); disp(cmt);
        % 6. with  region in an array
        [img,cmt] = read_xri_201313571(file_path,[],[50 100]);
        disp(img); disp(cmt);
        % 7. with region(all sides)
        %[img,cmt] = read_xri_201313571(file_path,[4 4],[1 20 1 40]);
        %disp(img); disp(cmt);
    end
end  
