% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function vdmFile = getVdmFile(BIDS, opt, boldFilename)
  %
  % returns the voxel displacement map associated with a given bold file
  %
  % USAGE::
  %
  %   vdmFile = getVdmFile(BIDS, opt, boldFilename)
  %
  % :param BIDS:
  % :type BIDS: structure
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param boldFilename:
  % :type opt: string
  %
  % :returns: - :vdmFile: (string)
  %

  vdmFile = '';

  fragments = bids.internal.parse_filename(boldFilename);

  if ~isfield(fragments, 'ses')
    fragments.ses = '';
  end

  modalities = bids.query(BIDS, 'modalities', ...
                          'sub', fragments.sub, ...
                          'ses', fragments.ses);

  if opt.useFieldmaps && any(ismember('fmap', modalities))
    % We loop through the field maps and find the one that is intended for this
    % bold file by reading from the metadata
    %
    % We break the loop when the file has been found

    fmapFiles = bids.query(BIDS, 'data', ...
                           'modality', 'fmap', ...
                           'sub', fragments.sub, ...
                           'ses', fragments.ses);

    fmapMetadata = bids.query(BIDS, 'metadata', ...
                              'modality', 'fmap', ...
                              'sub', fragments.sub, ...
                              'ses', fragments.ses);

    for  iFile = 1:size(fmapFiles, 1)

      intendedFor = fmapMetadata{iFile}.IntendedFor;

      if strfind(intendedFor, boldFilename) %#ok<STRIFCND>
        [pth, filename, ext] = spm_fileparts(fmapFiles{iFile});
        vdmFile = validationInputFile(pth, [filename ext], 'vdm5_sc');
        break
      end

    end

  end

  if isempty(vdmFile)
    warning('No voxel displacement map associated with: \n %s', boldFilename);
  end

end
