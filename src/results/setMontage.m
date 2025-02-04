% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function montage = setMontage(result)

  % TO DO
  % - adapt so that the background image is in MNI only if opt.space is MNI
  % - add possibility to easily select mean functional or the anatomical:
  %   - at the group level or subject level

  montage.background = {result.Output.montage.background};
  montage.orientation = result.Output.montage.orientation;
  montage.slices = result.Output.montage.slices;

end
