function file = setOrLoadFile( path, fileToLoad )

    if isfile(path)
        file = load( path, fileToLoad );   
    else
        file = struct();
    end

end

