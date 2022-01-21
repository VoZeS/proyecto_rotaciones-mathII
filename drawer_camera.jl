#EXERCISE MADE BY ERIK MARTÍN GARZÓN & DAVID BOCES OBIS
# the packages we need
using Gtk, Graphics, Logging, Printf

include("affin_transformation.jl")
#File opening and reading matrix and vor together
A=readdlm("circle.txt", Float64)

#Reading and saving matrix size
s=size(A)
s1=s[1] #rows
s2=s[2] #columns

# the main window
win = GtkWindow("SO(3)")

function init_canvas(h,w)
    # create the drawing canvas
    c = @GtkCanvas(h,w)

    # create the initial drawing inside a try/catch loop
    @guarded draw(c) do widget
        #  draw the background with the canvas drawing context
        # the code for this comes later
        draw_the_canvas(c)
    end

    show(c)
    return c
end

# make the canvas
the_canvas = init_canvas(1500,750)

# an array to store the entry boxes
entry_list = []

# an array of labels that we use to display normalized inputs,
# and which also gets modified from the callback
normalized_labels = []

function find_by_name(list, name)
    for item in list
        if get_gtk_property(item, :name, String) == name
            return item
        end
    end
    @warn name, "not found in list"
    @warn "available names are"
    for item in list
        @warn get_gtk_property(item, :name, String)
    end
end

function bold_label(label_string)
    label = GtkLabel("")
    GAccessor.markup(label, """<b>""" * label_string * """</b>""")
    return label
end

# Now put everything into the window,
# including the canvas
function init_window(win, canvas)
    # make a box for the drawing canvas
    canvas_box = GtkBox(:v)
    push!(canvas_box, bold_label("EJERCICIO 1:                                                                                                                                                          EJERCICIO 2:"))
    push!(canvas_box, bold_label("Proyecta los puntos del archivo al plano focal de la camara y dibuja el resultado.                                           Haz un dibujo 3d de toda la escena, con los dos sistemas ortonormales de coordenadas y
                                                                                                                                                                                                                                     los puntos de la circunferencia."))
    push!(canvas_box, canvas)

    # make a containing box that will stack the widgets and the canvas side by side
    global_box = GtkBox(:h)
    push!(global_box, GtkLabel("   ")) # a very basic separator
    push!(global_box, canvas_box)

    # put it all inside the window
    push!(win, global_box)
end

# the background drawing
function draw_the_canvas(canvas)
    h   = height(canvas)
    w   =  width(canvas)
    ctx =  getgc(canvas)

    # clear the canvas
    rectangle(ctx, 750, 0, w, h)
    set_source_rgb(ctx, 1, 1, 1)
    fill(ctx)

    # Paint red rectangle
    # rectangle(ctx, 3w/4, 0, w/4, h/4)
    # set_source_rgb(ctx, 1, 0, 0)
    # fill(ctx)

    # Paint blue rectangle
    # rectangle(ctx, 0, 3h/4, w/4, h/4)
    # set_source_rgb(ctx, 0, 0, 1)
    # fill(ctx)

    # Paint an example line
    # set_line_width(ctx, 5)
    # set_source_rgb(ctx, 1, 0, 1)
    # move_to(ctx, 10, 10)
    # line_to(ctx, 100, 50)
    # stroke(ctx)

    # ------------------------------------------------------------------ DATA
    originX = 850
    originY = 300

    #AXIS R3
    X = [1;0;0]
    Y = [0;1;0]
    Z = [0;0;1]

    #WE PROJECT THE ROTATED AXIS IN R3 TO R2
    X2 = to_2d(X)
    Y2 = to_2d(Y)
    Z2 = to_2d(Z)

    cam = [1;6;1]

    ay = 90
    az = -20
    focus = 3

    #Setting camera coords
    camCoord2d = to_2d(cam)*100

    #Camera axis rotations
    camXRY = rotate_phi_z(ay, Y, X)
    camYRY = rotate_phi_z(ay, Y, Y)
    camZRY = rotate_phi_z(ay, Y, Z)

    camXRZ = rotate_phi_z(az, camZRY, camXRY)
    camYRZ = rotate_phi_z(az, camZRY, camYRY)
    camZRZ = rotate_phi_z(az, camZRY, camZRY)

    camX2d = to_2d(camXRZ)
    camY2d = to_2d(camYRZ)
    camZ2d = to_2d(camZRZ)

    #Setting up variables we will need for calculations
    Ry = [cosd(ay) 0 sind(ay);0 1 0;-sind(ay) 0 cosd(ay)]
    Rz = [cosd(az) -sind(az) 0; sind(az) cosd(az) 0;0 0 1]
    C = Rz * Ry
    D = hcat(C, cam)
    B = vcat(D, [0 0 0 1])
    Binv = B^-1

    # for i=1:s1
    #     println(to_2d(focal_camera_points_in_space(B, focus, to_2d(focal_camera(Binv, focus, A[i,:])))[1:3,1]))
    #     println()
    #     println(focal_camera(Binv, focus, A[i,:]))
    # end

    # ----------------------------------------------------------- EXERCISE 3.1
    for i=1:s1
        circle(ctx, 375 + focal_camera(Binv, focus, A[i,:])[1]*100, 200 + focal_camera(Binv, focus, A[i,:])[2]*100, 1)
        set_source_rgb(ctx, 1, 0, 0)
        fill(ctx)
    end

    # ----------------------------------------------------------- EXERCISE 3.2
    # DRAW CANON BASIS
    #DRAW X AXIS CANON (RED)
    set_line_width(ctx, 2)
    set_source_rgb(ctx, 1, 0, 0)
    move_to(ctx, originX, originY)
    line_to(ctx, originX + X2[1]*100, originY - X2[2]*100)
    stroke(ctx)

    #circle at the end of the axis
    circle(ctx, originX + X2[1]*100, originY - X2[2]*100, 5)
    set_source_rgb(ctx, 1, 0, 0)
    fill(ctx)

    #DRAW Y AXIS CANON (GREEN)
    set_line_width(ctx, 2)
    set_source_rgb(ctx, 0, 1, 0)
    move_to(ctx, originX, originY)
    line_to(ctx, originX + Y2[1]*100, originY - Y2[2]*100)
    stroke(ctx)

    #circle at the end of the axis
    circle(ctx, originX + Y2[1]*100, originY - Y2[2]*100, 5)
    set_source_rgb(ctx, 0, 1, 0)
    fill(ctx)

    #DRAW Z AXIS CANON (BLUE)
    set_line_width(ctx, 2)
    set_source_rgb(ctx, 0, 0, 1)
    move_to(ctx, originX, originY)
    line_to(ctx, originX + Z2[1]*100, originY - Z2[2]*100)
    stroke(ctx)

    #circles at the end of the axis
    circle(ctx, originX + Z2[1]*100, originY - Z2[2]*100, 5)
    set_source_rgb(ctx, 0, 0, 1)
    fill(ctx)

    # DRAW CIRCLE POINTS IN SPACE
    for i=1:s1
        circle(ctx, originX + to_2d(A[i,:])[1]*100, originY - to_2d(A[i,:])[2]*100, 2)
        set_source_rgb(ctx, 0, 0, 1)
        fill(ctx)
    end

    # DRAW FOCAL CAMERA POINTS IN SPACE
    for i=1:s1
        circle(ctx, originX + to_2d(focal_camera_points_in_space(B, focus, focal_camera(Binv, focus, A[i,:])[1:2,:])[1:3,:])[1]*100,
         originY - to_2d(focal_camera_points_in_space(B, focus, focal_camera(Binv, focus, A[i,:])[1:2,:])[1:3,:])[2]*100, 1)
        set_source_rgb(ctx, 1, 0, 0)
        fill(ctx)
    end

    # WE DRAW THE AXIS' CAMERA
    #DRAW X AXIS CAMERA (RED)
    set_line_width(ctx, 1)
    set_source_rgb(ctx, 1, 0, 0)
    move_to(ctx, originX + camCoord2d[1], originY - camCoord2d[2])
    line_to(ctx, originX + camCoord2d[1] + camX2d[1]*50, originY - camCoord2d[2] - camX2d[2]*50)
    stroke(ctx)

    #circle at the end of the axis
    circle(ctx, originX + camCoord2d[1] + camX2d[1]*50, originY - camCoord2d[2] - camX2d[2]*50, 2)
    set_source_rgb(ctx, 1, 0, 0)
    fill(ctx)

    #DRAW Y AXIS CAMERA (GREEN)
    set_line_width(ctx, 1)
    set_source_rgb(ctx, 0, 1, 0)
    move_to(ctx, originX + camCoord2d[1], originY - camCoord2d[2])
    line_to(ctx, originX + camCoord2d[1] + camY2d[1]*50, originY - camCoord2d[2] - camY2d[2]*50)
    stroke(ctx)

    #circle at the end of the axis
    circle(ctx, originX + camCoord2d[1] + camY2d[1]*50, originY - camCoord2d[2] - camY2d[2]*50, 2)
    set_source_rgb(ctx, 0, 1, 0)
    fill(ctx)

    #DRAW Z AXIS CANON (BLUE)
    set_line_width(ctx, 1)
    set_source_rgb(ctx, 0, 0, 1)
    move_to(ctx, originX + camCoord2d[1], originY - camCoord2d[2])
    line_to(ctx, originX + camCoord2d[1] + camZ2d[1]*50, originY - camCoord2d[2] - camZ2d[2]*50)
    stroke(ctx)

    #circles at the end of the axis
    circle(ctx, originX + camCoord2d[1] + camZ2d[1]*50, originY - camCoord2d[2] - camZ2d[2]*50, 2)
    set_source_rgb(ctx, 0, 0, 1)
    fill(ctx)

    # LINES FORM EACH CIRCLE POINT TO ORIGIN CAMERA
    for i=1:s1
        set_line_width(ctx, 0.2)
        set_source_rgb(ctx, 0, 0.5, 1)
        move_to(ctx, originX + camCoord2d[1], originY - camCoord2d[2])
        line_to(ctx, originX + to_2d(A[i,:])[1]*100, originY - to_2d(A[i,:])[2]*100)
        stroke(ctx)
    end

    stroke(ctx)

end

# -------- initialize everything ---------


# prepare and show the initial widgets
init_window(win, the_canvas)
showall(win)
