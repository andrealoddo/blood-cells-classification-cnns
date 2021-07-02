function file = setOrLoadFile( path, fileToLoad )

    if isfile(path)
        file = struct();
    else
        file = load(path, fileToLoad );   
    end

end

