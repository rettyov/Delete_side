using NIfTI
using Gtk.ShortNames: maximize, showall 
using ImageView: closeall, imshow, roi, imshow_gui

function DisplayImage(ni; name = "ViewImage")
    closeall()
    zr, slicedata = roi(ni, (2,1))
    gd = imshow_gui((100, 100), slicedata, (1,1), name=name)
    imshow(gd["frame"], gd["canvas"], ni, nothing, zr, slicedata)
    maximize(showall(gd["window"]))
end

function BlackPixels(nii, (x, y, z); min = 1, max = 1)
    for i in min:max
        for j in 1:y
            for k in 1:z
                nii[i,j,k] = 0.
            end
        end
    end
end

for (root, dirs, files) in walkdir("./NII")
    println("Files in $root")
    for file in files
        println("\t",joinpath(root, file)) # path to files
        ni = niread(joinpath(root, file))
        nii = copy(ni)
        
        # show images
        DisplayImage(nii; name = file)
        
        
        x,y,z= size(ni)
        n = ""
        
        while n != "s"
            # o - original, l - left, r - right, s - save
            
            println("\n\t Enter command (o / l / r / s)")
            n = readline()
            if n == "l"
                nii = copy(ni) 
                
                BlackPixels(nii, (x, y, z); min = x÷2 + 1, max = x)        
                DisplayImage(nii; name = file)
                
            elseif n == "r"
                nii = copy(ni)
                
                BlackPixels(nii, (x, y, z); min = 1, max = x÷2)
                DisplayImage(nii; name = file)
                
            elseif n == "o"
                nii = copy(ni)
                
                DisplayImage(nii; name = file)
            end     
        end
        closeall()
        
        # create the new directory for new *.nii
        try
            mkdir("MyNII")
        catch
            nothing
        end
        
        nii = NIVolume(nii)
        niwrite("MyNII/" * file, nii)
        # println("Please, check dir: MyNII")
    end
end