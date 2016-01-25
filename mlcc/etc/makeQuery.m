function [ query ] = makeQuery( filename)
fileID = fopen(filename);
text = textscan(fileID,'%s','delimiter','\n');
text = text{1};
idxRem = strfind(text,'--');
for m=1:size(text,1)
    if ~isempty(idxRem{m})
        text{m}(idxRem{m}:end) = '';
    end
end
query = strjoin(text');
fclose(fileID);

end

