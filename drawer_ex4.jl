#EXERCISE MADE BY ERIK MARTÍN GARZÓN & DAVID BOCES OBIS
# the packages we need
using Gtk, Graphics, Logging, Printf

include("affin_transformation.jl")
#File opening and reading matrix and vor together

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
    push!(canvas_box, bold_label("EJERCICIO 4.4:                                                                                                                                                          EJERCICIO 4.5:"))
    push!(canvas_box, bold_label("                  Dibuja en 3d la escena, en las coordenadas globales.                                                                              Dibuja en 3d la misma escena, pero esta vez en las coordenadas de la camara."))
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
    originX = 200
    originY = 500

    #AXIS R3
    X = [1;0;0]
    Y = [0;1;0]
    Z = [0;0;1]

    #WE PROJECT THE ROTATED AXIS IN R3 TO R2
    X2 = to_2d(X)
    Y2 = to_2d(Y)
    Z2 = to_2d(Z)

    cam = [2.2837;5.0798;2.2328]

    angle = -150 #degree

    u = [0.01;-0.2;1.0] #camera's rotation AXIS

    #Setting camera coords
    camCoord2d = to_2d(cam)*100

    #Camera axis rotations
    camXR = rotate_phi_z(angle, u, X)
    camYR = rotate_phi_z(angle, u, Y)
    camZR = rotate_phi_z(angle, u, Z)

    camX2d = to_2d(camXR)
    camY2d = to_2d(camYR)
    camZ2d = to_2d(camZR)

    # n = hcat(camXR,camYR,camZR)
    # println(det(n))

    #Setting up variables we will need for calculations
    C = hcat(camXR, camYR, camZR)
    D = hcat(C, cam)
    B = vcat(D, [0 0 0 1])
    Binv = B^-1

    focus = 1

    for i=1:4
        println(B[i,:])
    end


    a = [0.9115;1.9397;3.3304]
    b = [3.7207;2.8794;4.4372]
    c = [1.9659;1.0000;3.2588]
    d = [2.6663;3.8191;4.5087]

    a2d = to_2d(a)
    b2d = to_2d(b)
    c2d = to_2d(c)
    d2d = to_2d(d)

    # --------------------------------------------------------------- EXERCISE 4.3 / 4.5
    focal_camera(Binv, focus, a)
    focal_camera(Binv, focus, b)
    focal_camera(Binv, focus, c)
    focal_camera(Binv, focus, d)

    println("Point a in the camera plane (Homogeneous): ", focal_camera(Binv, focus, a))
    println("Point b in the camera plane (Homogeneous): ", focal_camera(Binv, focus, b))
    println("Point c in the camera plane (Homogeneous): ", focal_camera(Binv, focus, c))
    println("Point d in the camera plane (Homogeneous): ", focal_camera(Binv, focus, d))

    # DRAW POINTS a, b, c, d AND ITS SEGMENTS
    # a BLUE
    circle(ctx, 1000 + focal_camera(Binv, focus, a)[1]*100, 300 - focal_camera(Binv, focus, a)[2]*100, 3)
    set_source_rgb(ctx, 0, 0, 1)
    fill(ctx)

    # b RED
    circle(ctx, 1000 + focal_camera(Binv, focus, b)[1]*100, 300 - focal_camera(Binv, focus, b)[2]*100, 3)
    set_source_rgb(ctx, 1, 0, 0)
    fill(ctx)

    # c PURPLE
    circle(ctx, 1000 + focal_camera(Binv, focus, c)[1]*100, 300 - focal_camera(Binv, focus, c)[2]*100, 3)
    set_source_rgb(ctx, 1, 0, 1)
    fill(ctx)

    # d BLUE
    circle(ctx, 1000 + focal_camera(Binv, focus, d)[1]*100, 300 - focal_camera(Binv, focus, d)[2]*100, 3)
    set_source_rgb(ctx, 0, 1, 0)
    fill(ctx)

    # DRAW SEGMENTS
    # ab
    set_line_width(ctx, 1)
    set_source_rgb(ctx, 0, 0, 0)
    move_to(ctx, 1000 + focal_camera(Binv, focus, a)[1]*100, 300 -  focal_camera(Binv, focus, a)[2]*100)
    line_to(ctx, 1000 + focal_camera(Binv, focus, b)[1]*100, 300 - focal_camera(Binv, focus, b)[2]*100)
    stroke(ctx)

    # cd
    set_line_width(ctx, 1)
    set_source_rgb(ctx, 0, 0, 0)
    move_to(ctx, 1000 + focal_camera(Binv, focus, c)[1]*100, 300 - focal_camera(Binv, focus, c)[2]*100)
    line_to(ctx, 1000 + focal_camera(Binv, focus, d)[1]*100, 300 - focal_camera(Binv, focus, d)[2]*100)
    stroke(ctx)

    # --------------------------------------------------------------- EXERCISE 4.4
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

    # DRAW POINTS a, b, c, d AND ITS SEGMENTS
    # a BLUE
    circle(ctx, originX + a2d[1]*100, originY - a2d[2]*100, 3)
    set_source_rgb(ctx, 0, 0, 1)
    fill(ctx)

    # b RED
    circle(ctx, originX + b2d[1]*100, originY - b2d[2]*100, 3)
    set_source_rgb(ctx, 1, 0, 0)
    fill(ctx)

    # c PURPLE
    circle(ctx, originX + c2d[1]*100, originY - c2d[2]*100, 3)
    set_source_rgb(ctx, 1, 0, 1)
    fill(ctx)

    # d BLUE
    circle(ctx, originX + d2d[1]*100, originY - d2d[2]*100, 3)
    set_source_rgb(ctx, 0, 1, 0)
    fill(ctx)

    # DRAW SEGMENTS
    # ab
    set_line_width(ctx, 1)
    set_source_rgb(ctx, 0, 0, 0)
    move_to(ctx, originX +  a2d[1]*100, originY -  a2d[2]*100)
    line_to(ctx, originX + b2d[1]*100, originY - b2d[2]*100)
    stroke(ctx)

    # cd
    set_line_width(ctx, 1)
    set_source_rgb(ctx, 0, 0, 0)
    move_to(ctx, originX +  c2d[1]*100, originY -  c2d[2]*100)
    line_to(ctx, originX + d2d[1]*100, originY - d2d[2]*100)
    stroke(ctx)

    # LINES FORM EACH POINT TO ORIGIN CAMERA
    set_line_width(ctx, 0.2)
    set_source_rgb(ctx, 0, 0.5, 1)
    move_to(ctx, originX + camCoord2d[1], originY - camCoord2d[2])
    line_to(ctx, originX + a2d[1]*100, originY - a2d[2]*100)
    stroke(ctx)

    set_line_width(ctx, 0.2)
    set_source_rgb(ctx, 0, 0.5, 1)
    move_to(ctx, originX + camCoord2d[1], originY - camCoord2d[2])
    line_to(ctx, originX + b2d[1]*100, originY - b2d[2]*100)
    stroke(ctx)

    set_line_width(ctx, 0.2)
    set_source_rgb(ctx, 0, 0.5, 1)
    move_to(ctx, originX + camCoord2d[1], originY - camCoord2d[2])
    line_to(ctx, originX + c2d[1]*100, originY - c2d[2]*100)
    stroke(ctx)

    set_line_width(ctx, 0.2)
    set_source_rgb(ctx, 0, 0.5, 1)
    move_to(ctx, originX + camCoord2d[1], originY - camCoord2d[2])
    line_to(ctx, originX + d2d[1]*100, originY - d2d[2]*100)
    stroke(ctx)

    stroke(ctx)

end

# -------- initialize everything ---------


# prepare and show the initial widgets
init_window(win, the_canvas)
showall(win)
