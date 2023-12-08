fname = ".\data\2d_1k_5ki.json";

fid = fopen(fname);
raw = fread(fid,inf);
str = char(raw');
fclose(fid);
val = jsondecode(jsondecode(str));

plt
