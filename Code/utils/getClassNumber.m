function classNumber = getClassNumber( dataset )

    if( contains(dataset, 'ALL_IDB') )
        classNumber = 2;
    elseif( contains(dataset, 'Raabin') )
        classNumber = 5;
    end

end
