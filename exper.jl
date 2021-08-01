import Base.+
import Base.-
import Base.*
import Base.zero
using Images
using ColorTypes

function zero((x1,x2,x3)::Tuple{Float64, Float64, Float64})
    return (0.0,0.0,0.0)
end

function +((x1,x2,x3)::Tuple{Float64, Float64, Float64}, (y1,y2,y3)::Tuple{Float64, Float64, Float64})
    return (x1+y1,x2+y2,x3+y3)
end

function -((x1,x2,x3)::Tuple{Float64, Float64, Float64}, (y1,y2,y3)::Tuple{Float64, Float64, Float64})
    return (x1-y1,x2-y2,x3-y3)
end

function *((x1,x2,x3)::Tuple{Float64, Float64, Float64}, y::Float64)
    return (x1*y,x2*y,x3*y)
end
function *(y::Float64, (x1,x2,x3)::Tuple{Float64, Float64, Float64})
    return (x1*y,x2*y,x3*y)
end

function norm((x1,x2,x3)::Tuple{Float64, Float64, Float64})
    return sqrt(x1*x1+x2*x2+x3*x3)
end

function *((x1,x2,x3)::Tuple{Float64, Float64, Float64}, (y1,y2,y3)::Tuple{Float64, Float64, Float64})
    return (x2*y3+x3*y2-2*x1*y1,-x1*y3-x3*y1+2*x2*y2,x1*y2+x2*y1-2*x3*y3)
end

function zero((x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64})
    return (0.0,0.0,0.0,0.0)
end
function +((x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64},
           (y1,y2,y3,y4)::Tuple{Float64, Float64, Float64, Float64})
    return (x1+y1,x2+y2,x3+y3,x4+y4)
end

function -((x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64},
           (y1,y2,y3,y4)::Tuple{Float64, Float64, Float64, Float64})
    return (x1-y1,x2-y2,x3-y3, x4-y4)
end

function *((x1,x2,x3, x4)::Tuple{Float64, Float64, Float64, Float64}, y::Float64)
    return (x1*y,x2*y,x3*y,x4*y)
end
function *(y::Float64, (x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64})
    return (x1*y,x2*y,x3*y,x4*y)
end

function norm((x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64})
    return sqrt(x1*x1+x2*x2+x3*x3+x4*x4)
end

function *((x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64},
           (y1,y2,y3,y4)::Tuple{Float64, Float64, Float64, Float64})
    return (x1*y1-x2*y2-x3*y3-x4*y4,x2*y1+x2*y1+x3*y4+x4*y3,x3*y1+x1*y3+x2*y4+x4*y2,x1*y4+x4*y1+x2*y3+x3*y2)
end

function myimage(x::Float64,y::Float64,z::Float64,u::Float64,
                 radius::Float64,limit::Float64,size::Int64)
    image=Matrix{RGB}(UndefInitializer(),size,size)
    step = radius*2.0/convert(Float64,size)
    colorstepsOneColor=256
    colorsteps=6*colorstepsOneColor
    gray = 1.0/convert(Float64,colorstepsOneColor)
    colors=Array{RGB}(UndefInitializer(),colorsteps)
    for ii in 1:colorstepsOneColor
        scaledgray=gray*ii
        colors[ii]=RGB(scaledgray,0.0,0.0)
        colors[2*ii+colorstepsOneColor]=RGB(0.0,scaledgray,0.0)
        colors[2*ii-1+colorstepsOneColor]=RGB(0.0,scaledgray,0.0)
        colors[3*ii+3*colorstepsOneColor]=RGB(0.0,0.0,scaledgray)
        colors[3*ii-1+3*colorstepsOneColor]=RGB(0.0,0.0,scaledgray)
        colors[3*ii-2+3*colorstepsOneColor]=RGB(0.0,0.0,scaledgray)
    end
    black=RGB(0.0,0.0,0.0)
    xpos = x-radius
    for i in 1:size
        ypos = y-radius
        for j in 1:size
            n=1
            c=(xpos,ypos,z,u)
            v=(0.0,0.0,0.0,0.0)
            while true
                if norm(v)>=limit
                    color=gray*convert(Float64,n)
                    image[i,j] = colors[n]
                    break
                end
                if n>colorsteps-1
                    image[i,j] = black
                    break
                end
                n += 1
                v = v * v + c
            end
            ypos += step
        end
        xpos += step
    end
    return image
end

function mydraw(fn::String,x::Float64,y::Float64,z::Float64,u::Float64,
                radius::Float64,limit::Float64,size::Int64)
    image=myimage(x,y,z,u,radius,limit,size)
    save(fn,image)
end
