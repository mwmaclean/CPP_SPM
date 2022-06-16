function pth = pathToPrint(pth)
  %
  % Replaces single '\' by '/' on Windows
  % to prevent escaping warning when printing a path
  %
  % :param pth: If pth is a cellstr of paths, pathToPrint will work
  %             recursively on it.
  % :type pth: char or cellstr
  %
  % (C) Copyright 2021 CPP_SPM developers

  if isunix()
    return
  end

  if ischar(pth)
    pth = strrep(pth, '\', '/');

  elseif iscell(pth)
    for i = 1:numel(pth)
      pth{i} = pathToPrint(pth{i});
    end
  end

end
