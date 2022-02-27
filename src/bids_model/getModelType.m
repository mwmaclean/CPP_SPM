function modelType = getModelType(modelFile, nodeType)
  %
  % returns the model type of node of a BIDS statistical model
  %
  % (C) Copyright 2021 CPP_SPM developers

  modelType = '';

  if isempty(modelFile)
    return
  end
  if nargin < 2 || isempty(nodeType)
    nodeType = 'run';
  end

  bm = bids.Model('file', modelFile);
  node = bm.get_nodes('Level', nodeType);

  try
    modelType = node.Model.Type;
  catch
    msg = sprintf('Unknown model type for node %s in BIDS model file\n%s.\nAssuming it is GLM.', ...
                  nodeType, modelFile);
    errorHandling(mfilename(), 'unknownModelType', msg, true, true);
    modelType = 'glm';
  end

  if ~strcmpi(modelType, 'glm')
    msg = sprintf('The model type is not GLM for node %s in BIDS model file\n%s', ...
                  nodeType, modelFile);
    errorHandling(mfilename(), 'notGLM', msg, false, true);
  end

end
