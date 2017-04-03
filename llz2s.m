function [sxyz,sx,sy,sz] = llz2s(lat,lon,z,varargin)
% Written by Matthew P. Humphreys - last updated 2015-02-05

if length(varargin) == 2
    centrepoint = varargin{1};
    earthradius = varargin{2};
elseif length(varargin) == 1
    centrepoint = varargin{1};
    earthradius = 6371;
else
    centrepoint = [90 0];
    earthradius = 6371;
end %if

r = earthradius - z/1000;

[sx,sy,sz] = sph2cart(degtorad(lon-centrepoint(2)),degtorad(lat),r);

rot = (90 - centrepoint(1)) * pi/180;

[stheta,srho] = cart2pol(sx,sz);
stheta = stheta + rot;
[sx,sz] = pol2cart(stheta,srho);

sx0 = sx;
sy0 = sy;
sx = sy0;
sy = -sx0;

sxyz = [sx sy sz];

end %function llz2s