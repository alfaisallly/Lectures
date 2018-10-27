function [r,g,b] = yuv2rgb(y,i,q)
%NTSC2RGB Convert NTSC values to RGB color space.
%   RGBMAP = NTSC2RGB(YIQMAP) converts the M-by-3 NTSC
%   (television) values in the colormap YIQMAP to RGB color
%   space. If YIQMAP is M-by-3 and contains the NTSC luminance
%   (Y) and chrominance (I and Q) color components as columns,
%   then RGBMAP is an M-by-3 matrix that contains the red, green,
%   and blue values equivalent to those colors.  Both RGBMAP and
%   YIQMAP contain intensities in the range 0.0 to 1.0. The
%   intensity 0.0 corresponds to the absence of the component,
%   while the intensity 1.0 corresponds to full saturation of the
%   component.
%
%   RGB = NTSC2RGB(YIQ) converts the NTSC image YIQ to the
%   equivalent truecolor image RGB.
%
%   Class Support
%   -------------
%   The input image or colormap must be of class double. The
%   output is of class double.
%
%   See also RGB2NTSC, RGB2IND, IND2RGB, IND2GRAY.

%   Copyright 1993-2001 The MathWorks, Inc.  
%   $Revision: 5.13 $  $Date: 2001/01/18 15:30:12 $

T = [1.0 0 1.1398; 1.0 -0.3946 -0.5805; 1.0 2.0320 -0.0005];

if nargin==0 | nargin==2, 
  error('Wrong number of input arguments.');
end

threeD = (ndims(y)==3); % Determine if input includes a 3-D array.

if (nargin==1 & ~threeD),
  [m,n] = size(y);
  if n~=3, error('YIQ must have 3 columns.'); end
  r = y*T';
 
  % Make sure the rgb values are between 0.0 and 1.0
  r = max(0,r);
  d = find(any(r'>1));
  r(d,:) = r(d,:)./(max(r(d,:)')'*ones(1,3));
else
  if threeD,
    m = size(y,1); n = size(y,2);
    rgb = reshape(y(:),m*n,3)*T';
  else 
    [m,n] = size(y);
    if any(size(y)~=size(i)) | any(size(y)~=size(q)),
      error('Y,I,Q must all be the same size.');
    end
    rgb = [y(:) i(:) q(:)]*T';
  end

  % Make sure the rgb values are between 0.0 and 1.0
  rgb = max(0,rgb);
  d = find(any(rgb'>1));
  rgb(d,:) = rgb(d,:)./(max(rgb(d,:)')'*ones(1,3));

  if (nargout==0 | nargout==1)
    r = reshape(rgb,size(y,1),size(y,2),3);
  else
    r = reshape(rgb(:,1),m,n);
    g = reshape(rgb(:,2),m,n);
    b = reshape(rgb(:,3),m,n);
  end
end
