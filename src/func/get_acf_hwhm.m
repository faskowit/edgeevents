function [acfs,acs_twosided] = get_acf_hwhm(inTs,inTr,nLags) 

if nargin < 2
    error('need 2 args')
end

if nargin < 3
    nLags = 20 ; 
end

warning('off')
acs_onsided = cell2mat(arrayfun(@(i_) autocorr(double(inTs(:,i_)),nLags),1:size(inTs,2),...
    'UniformOutput',false)) ; 
warning('on')

acs_twosided = vertcat( flipud(acs_onsided(2:end,:)) , acs_onsided ) ; 

acfs = cell2mat(arrayfun(@(i_) acf_hwhm_ts(acs_twosided(:,i_),inTr), 1:size(inTs,2),...
    'UniformOutput',false)) ; 

end

function out_hwhm = acf_hwhm_ts(acf,tr)

% acf should be time (lags) vs. nodes (see spectral_template.m)
% tr is sampling interval (seconds)
% out_hwhm is a row 1xnodes vector of intrinsic timescale estimates,
% computed as half of the full-width-at-half-max

out_hwhm = nan(1,size(acf,2));
good_mask = sum(isnan(acf))==0;
acf = acf(:,good_mask);

nlags = (size(acf,1)-1)/2; % number of time shifts for acf
num_nodes = size(acf,2);
lags = tr*(-nlags:nlags);
fwhm = nan(1,num_nodes);

pp = spline(lags,acf');
coefs = reshape(pp.coefs,num_nodes,size(acf,1)-1,4);
coefs(:,:,end) = coefs(:,:,end)-.5;
pp.dim = 1;
for n = 1:num_nodes
    % disp(num2str(n))
    pp.coefs = squeeze(coefs(n,:,:));
    xval = fnzeros(pp);
    try
        fwhm(n) = 2*abs(xval(1));
    catch
        fwhm(n) = nan;
    end
end

out_hwhm(good_mask) = fwhm/2;


end