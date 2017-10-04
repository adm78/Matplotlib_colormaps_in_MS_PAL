%% Name:		cmap2pal.m
%% Description:	Converts matlab colormaps to binary .pal format
%% Authors:		M.J.P Alcocer [marcelo.j.p.alcocer@gmail.com]
%%
%% Version:		1.0 (2013.08.17)
%% Changelog:	2013.08.17:	First version posted on File Exchange
%%
%% Licensing:	Copyright © 2013, M.J.P Alcocer
%%				All rights reserved.
%%				http://opensource.org/licenses/bsd-license.php
%%
%% Acknowledgements:
%%
%%				.pal Format:	http://willperone.net/Code/codereadingpal.php
%%								http://worms2d.info/Palette_file
%%								http://www.johnloomis.org/cpe102/asgn/asgn1/riff.html
%%
%%				Thumbnail showing cool-warm colormap created using cptcmap, copyright 2011 Kelly Kearney
%%				(http://www.mathworks.it/matlabcentral/fileexchange/28943-color-palette-tables-cpt-for-matlab)

function cmap2pal(cmap,varargin)

	% CMAP2PAL Convert matlab colormap to binary .pal format
	%
	%	CMAP2PAL(cmap) converts the matlab colormap cmap into binary .pal format.
	%	cmap must be an nx3 array of RGB values between 0 and 1. The output file
	%	destination is selected via a GUI.
	%
	%	CMAP2PAL(cmap,path) saves the .pal file to the detination specified by path.
	
	
	%% GUI path selection (if no path argument or directory)
	exts={'*.pal','Binary Palette File (*.pal)';'*.*','All Files (*.*)'};
	if(isempty(varargin))
		[file_name,file_dir,filter_index]=uiputfile(exts,'Save palette file');					%% No argument
		path=[file_dir,file_name];
	elseif(isdir(varargin{1}))
		[file_name,file_dir,filter_index]=uiputfile(exts,'Save palette file',varargin{1});		%% Directory argument
		path=[file_dir,file_name];
	
	%% Validate manual path extension
	else
		path=varargin{1};																		%% Path argument
		[file_dir,file_name,file_ext]=fileparts(path);		
		switch(file_ext)
			case ''
				filter_index=2;
			case '.pal'
				filter_index=1;
			otherwise
				warning('cmap2pal:FileExt','File extension not .pal (%s). Changing extension to .pal',file_ext);
				path=[file_dir,file_name];
				filter_index=2;		
		end
		
	end
	
	%% Catch cancel from uiputfile
	if(filter_index==0)
		return
		
	%% Add .pal extension if missing
	elseif(filter_index==2)
		path=[path,'.pal'];
	end
	
	%% Definitions
	mf='n';								% Machine format
	depth=size(cmap,1);					% Colormap depth
	hlen=24;							% Header length
	flen=hlen+(4*depth);
	
	%% Open file
	fid=fopen(path,'w',mf);
	if(fid<0)
		throw(MException('cmap2pal:Open','Error opening file (%s) for writing',path));
	end

	%% Write RIFF signature
	fwrite(fid,'RIFF','uint8',0,mf);
	
	%% Write file length
	fwrite(fid,flen-8,'uint32',0,mf);								% 8 byte header (RIFF header)
	
	%% Write PAL signature
	fwrite(fid,'PAL ','uint8',0,mf);
	
	%% Write data signature
	fwrite(fid,'data','uint8',0,mf);
	
	%% Write data block size
	fwrite(fid,flen-20,'uint32',0,mf);								% 20 byte header (RIFF + Chunk)
	
	%% Write version number
	fwrite(fid,[0,3],'uint8',0,mf);									% Always 3
	
	%% Write palette length
	fwrite(fid,depth,'uint16',0,mf);
	
	%% Write palette data
	fwrite(fid,[cmap.*255,zeros(depth,1)]','uint8',0,mf);			% RGBA tuples
	
	%% Close file
	fclose(fid);
	
end