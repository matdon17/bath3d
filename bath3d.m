function [g,LS] = bath3d(g,fres,vex,cp_latlon,lights,bb_z,aquabox,cva)
%bath3d
% Written by Matthew P. Humphreys - last updated 2016-12-15
% ============================================================== Inputs ===
% g        = gridded bathymetry data
%  .lat = latitude  / deg N [-90 to +90]
%  .lon = longitude / deg E [-180 to +180]
%  .z   = depth     / m     [-ve for above sea level]
% fres     = bathymetry resolution
% vex      = vertical exaggeration
% cpLatLon = [lat lon] of centre point (for vertical rotation axis);

% ===================================== Convert bathymetry co-ordinates ===
[~,X,Y,Z] = llz2s(g.lat(:),g.lon(:),g.z(:)*vex,cp_latlon);
g.sx = NaN(size(g.lon)); g.sy = g.sx; g.sz = g.sx;
g.sx(:) = X; g.sy(:) = Y; g.sz(:) = Z;
bbL = g.z > bb_z;
[~,g.sx(bbL),g.sy(bbL),g.sz(bbL)] ...
    = llz2s(g.lat(bbL),g.lon(bbL),bb_z*vex,cp_latlon);
    
% ===================================================== Figure settings ===
set(gcf, 'color','k', 'inverthardcopy','off'); hold on;

% ================================================== Bathymetry surface ===
surf(g.sx(1:fres:end,1:fres:end), ...
     g.sy(1:fres:end,1:fres:end), ...
     g.sz(1:fres:end,1:fres:end), ...
     g.z(1:fres:end,1:fres:end), 'edgecolor','none', ...
     'facelighting','gouraud');

% ===================================================== Axis appearance ===
ca = gca;
ca.Color = 'k';
ca.XColor = 'none';
ca.YColor = 'none';
ca.ZColor = 'none';

% ========================================================== Colour map ===
bathmap = [198,219,239;
    107,174,214;
    66,146,198;
    33,113,181;
    8,81,156;
    8,48,107;
    4,24,54] / 255;
landmap = [173,221,142;
    120,198,121;
    65,171,93;
    35,132,67;
    0,104,55;
    0,69,41] / 255;
demcmap(minmax(g.z(:)'),255,landmap,bathmap);
% demcmap(minmax(g.z(:)'),255,rgb2gray(bathmap),rgb2gray(landmap));

% ======================================================= View settings ===
% ==== Central bird's-eye view ====
ca.CameraViewAngle = cva;
view(0,90);
% ==== Permanent settings ====
ca.Projection = 'perspective';
ca.CameraViewAngleMode = 'manual';
ca.DataAspectRatio = [1 1 1];

% ================================================= Material & lighting ===
material([0.75, 0.4, 0, 10, 1]);
if isempty(lights)
    lights = [0 cp_latlon(2) -1.5e11];
end %if
LSpos = llz2s(lights(:,1),lights(:,2),lights(:,3)*vex,cp_latlon);
for L = 1:size(LSpos,1)
    LS.(['l' num2str(L)]) = light('position',LSpos(L,:), 'style','local');
end %for L

% =============================================== BB BLACK BOX settings ===
% AQUABOX
if aquabox
ab_z = 0;
ab_face = 'w';
ab_edge = [0.2 0.5 1];
ab_alpha = 0;
% AB Resolution adjustments
endr = 1:size(g.sx,1);
endr = endr(1:fres:end);
endr = endr(end);
endc = 1:size(g.sx,2);
endc = endc(1:fres:end);
endc = endc(end);
% AB Bottom edges - WEST
ab_w = track([g.lat(1,endc); g.lat(1,1)], ...
    [g.lon(1,endc); g.lon(1,1)]);
ab_w = ab_w(~isnan(ab_w(:,1)),:);
ab_w(:,3:5) = llz2s(ab_w(:,1),ab_w(:,2),ab_z*vex,cp_latlon);
% AB Bottom edges - NORTH
ab_n = track([g.lat(1,1); g.lat(endr,1)], ...
    [g.lon(1,1); g.lon(endr,1)]);
ab_n = ab_n(~isnan(ab_n(:,1)),:);
ab_n(:,3:5) = llz2s(ab_n(:,1),ab_n(:,2),ab_z*vex,cp_latlon);
% AB Bottom edges - EAST
ab_e = track([g.lat(endr,endc); g.lat(endr,1)], ...
    [g.lon(endr,endc); g.lon(endr,1)]);
ab_e = ab_e(~isnan(ab_e(:,1)),:);
ab_e(:,3:5) = llz2s(ab_e(:,1),ab_e(:,2),ab_z*vex,cp_latlon);
% AB Bottom edges - SOUTH
ab_s = track([g.lat(1,endc); g.lat(endr,endc)], ...
    [g.lon(1,endc); g.lon(endr,endc)]);
ab_s = ab_s(~isnan(ab_s(:,1)),:);
ab_s(:,3:5) = llz2s(ab_s(:,1),ab_s(:,2),ab_z*vex,cp_latlon);
% AB Define patches
ab_pw = [ab_w(:,3:5); ...
    g.sx(1,1:fres:end)' g.sy(1,1:fres:end)' g.sz(1,1:fres:end)'];
ab_pn = [ab_n(:,3:5); ...
    g.sx(endr:-fres:1,1) g.sy(endr:-fres:1,1) g.sz(endr:-fres:1,1)];
ab_pe = [ab_e(:,3:5); ...
    g.sx(endr,1:fres:end)' g.sy(endr,1:fres:end)' g.sz(endr,1:fres:end)'];
ab_ps = [ab_s(:,3:5); ...
    g.sx(endr:-fres:1,endc) g.sy(endr:-fres:1,endc) ...
    g.sz(endr:-fres:1,endc)];
ab_b = [ab_w(:,3:5); ab_n(:,3:5); ab_e(end:-1:1,3:5); ab_s(end:-1:1,3:5)];
% AB Draw patches
patch(ab_pw(:,1),ab_pw(:,2),ab_pw(:,3),ab_face, ...
    'edgecolor',ab_edge, 'facelighting','none', 'facealpha',ab_alpha);
patch(ab_pn(:,1),ab_pn(:,2),ab_pn(:,3),ab_face, ...
    'edgecolor',ab_edge, 'facelighting','none', 'facealpha',ab_alpha);
patch(ab_pe(:,1),ab_pe(:,2),ab_pe(:,3),ab_face, ...
    'edgecolor',ab_edge, 'facelighting','none', 'facealpha',ab_alpha);
patch(ab_ps(:,1),ab_ps(:,2),ab_ps(:,3),ab_face, ...
    'edgecolor',ab_edge, 'facelighting','none', 'facealpha',ab_alpha);
patch(ab_b(:,1),ab_b(:,2),ab_b(:,3),ab_face, ...
    'edgecolor',ab_edge, 'facelighting','none', 'facealpha',ab_alpha);
end %if aquabox
% BLACK BOX BEGIN
bb_face = 0.15*[1 1 1];
bb_edge = 0.65*[1 1 1];
% BB Resolution adjustments
endr = 1:size(g.sx,1);
endr = endr(1:fres:end);
endr = endr(end);
endc = 1:size(g.sx,2);
endc = endc(1:fres:end);
endc = endc(end);
% BB Bottom edges - WEST
bb_w = track([g.lat(1,endc); g.lat(1,1)], ...
    [g.lon(1,endc); g.lon(1,1)]);
bb_w = bb_w(~isnan(bb_w(:,1)),:);
bb_w(:,3:5) = llz2s(bb_w(:,1),bb_w(:,2),bb_z*vex,cp_latlon);
% BB Bottom edges - NORTH
bb_n = track([g.lat(1,1); g.lat(endr,1)], ...
    [g.lon(1,1); g.lon(endr,1)]);
bb_n = bb_n(~isnan(bb_n(:,1)),:);
bb_n(:,3:5) = llz2s(bb_n(:,1),bb_n(:,2),bb_z*vex,cp_latlon);
% BB Bottom edges - EAST
bb_e = track([g.lat(endr,endc); g.lat(endr,1)], ...
    [g.lon(endr,endc); g.lon(endr,1)]);
bb_e = bb_e(~isnan(bb_e(:,1)),:);
bb_e(:,3:5) = llz2s(bb_e(:,1),bb_e(:,2),bb_z*vex,cp_latlon);
% BB Bottom edges - SOUTH
bb_s = track([g.lat(1,endc); g.lat(endr,endc)], ...
    [g.lon(1,endc); g.lon(endr,endc)]);
bb_s = bb_s(~isnan(bb_s(:,1)),:);
bb_s(:,3:5) = llz2s(bb_s(:,1),bb_s(:,2),bb_z*vex,cp_latlon);
% BB Define patches
bb_pw = [bb_w(:,3:5); ...
    g.sx(1,1:fres:end)' g.sy(1,1:fres:end)' g.sz(1,1:fres:end)'];
bb_pn = [bb_n(:,3:5); ...
    g.sx(endr:-fres:1,1) g.sy(endr:-fres:1,1) g.sz(endr:-fres:1,1)];
bb_pe = [bb_e(:,3:5); ...
    g.sx(endr,1:fres:end)' g.sy(endr,1:fres:end)' g.sz(endr,1:fres:end)'];
bb_ps = [bb_s(:,3:5); ...
    g.sx(endr:-fres:1,endc) g.sy(endr:-fres:1,endc) ...
    g.sz(endr:-fres:1,endc)];
bb_b = [bb_w(:,3:5); bb_n(:,3:5); bb_e(end:-1:1,3:5); bb_s(end:-1:1,3:5)];
% BB Draw patches
patch(bb_pw(:,1),bb_pw(:,2),bb_pw(:,3),bb_face, ...
    'edgecolor',bb_edge, 'facelighting','none');
patch(bb_pn(:,1),bb_pn(:,2),bb_pn(:,3),bb_face, ...
    'edgecolor',bb_edge, 'facelighting','none');
patch(bb_pe(:,1),bb_pe(:,2),bb_pe(:,3),bb_face, ...
    'edgecolor',bb_edge, 'facelighting','none');
patch(bb_ps(:,1),bb_ps(:,2),bb_ps(:,3),bb_face, ...
    'edgecolor',bb_edge, 'facelighting','none');
patch(bb_b(:,1),bb_b(:,2),bb_b(:,3),bb_face, ...
    'edgecolor',bb_edge, 'facelighting','none');

end %function bath3d