function timeExtraction = setOrLoadFile(timeDestination)

    if isfile(timeDestination)
        timeExtraction = struct();
    else
        load(timeDestination, 'timeExtraction');   
    end

end

