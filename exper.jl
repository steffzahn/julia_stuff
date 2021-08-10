import Base.+
import Base.-
import Base.*
import Base./
import Base.zero
import Base.one
import Base.inv
using Images
using ColorTypes

function zero((x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64}
              )::Tuple{Float64, Float64, Float64, Float64}
    return (0.0,0.0,0.0,0.0)
end

function one((x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64}
             )::Tuple{Float64, Float64, Float64, Float64}
    return (1.0,0.0,0.0,0.0)
end

function +((x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64},
           (y1,y2,y3,y4)::Tuple{Float64, Float64, Float64, Float64}
           )::Tuple{Float64, Float64, Float64, Float64}
    return (x1+y1,x2+y2,x3+y3,x4+y4)
end

function -((x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64},
           (y1,y2,y3,y4)::Tuple{Float64, Float64, Float64, Float64}
           )::Tuple{Float64, Float64, Float64, Float64}
    return (x1-y1,x2-y2,x3-y3, x4-y4)
end
function -((x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64}
           )::Tuple{Float64, Float64, Float64, Float64}
    return (-x1,-x2,-x3,-x4)
end

function *((x1,x2,x3, x4)::Tuple{Float64, Float64, Float64, Float64}, y::Float64
           )::Tuple{Float64, Float64, Float64, Float64}
    return (x1*y,x2*y,x3*y,x4*y)
end
function *(y::Float64, (x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64}
           )::Tuple{Float64, Float64, Float64, Float64}
    return (x1*y,x2*y,x3*y,x4*y)
end

# \cdot tab
function ⋅((x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64},
          (y1,y2,y3,y4)::Tuple{Float64, Float64, Float64, Float64})::Float64
    return x1*y1+x2*y2+x3*y3+x4*y4
end

function norm(x::Tuple{Float64, Float64, Float64, Float64})::Float64
    return sqrt(x ⋅ x)
end
function normalize(a::Tuple{Float64, Float64, Float64, Float64}
                   )::Tuple{Float64, Float64, Float64, Float64}
    n=norm(a)
    if n==0.0
        return a
    end
    return (1.0/n)*a
end

function conj((x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64}
             )::Tuple{Float64, Float64, Float64, Float64}
    return (x1,-x2,-x3,-x4)
end

function inv((x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64}
             )::Tuple{Float64, Float64, Float64, Float64}
    return (1.0/(x1*x1+x2*x2+x3*x3+x4*x4))*(x1,-x2,-x3,-x4)
end

function *((x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64},
           (y1,y2,y3,y4)::Tuple{Float64, Float64, Float64, Float64}
           )::Tuple{Float64, Float64, Float64, Float64}
    return (x1*y1-x2*y2-x3*y3-x4*y4,
            x2*y1+x1*y2+x3*y4-x4*y3,
            x3*y1+x1*y3-x2*y4+x4*y2,
            x1*y4+x4*y1+x2*y3-x3*y2)
end

function /(a::Tuple{Float64, Float64, Float64, Float64},
           b::Tuple{Float64, Float64, Float64, Float64}
           )::Tuple{Float64, Float64, Float64, Float64}
    return a*inv(b)
end

function initPalette(;colorScheme::Int64=0)::Tuple{Vector{RGB},Int64}
    colorstepsOneColor=256
    colorsteps=6*colorstepsOneColor
    gray = 1.0/convert(Float64,colorstepsOneColor)
    colors=Array{RGB}(UndefInitializer(),colorsteps)
    for ii in 1:colorstepsOneColor
        scaledgray=gray*ii
        red=RGB(scaledgray,0.0,0.7*scaledgray)
        green=RGB(0.0,scaledgray,0.8*scaledgray)
        blue=RGB(0.4*scaledgray,0.0,scaledgray)
        if colorScheme == 1
            color1=blue
            color2=red
            color3=green
        elseif colorScheme == 2
            color1=green
            color2=blue
            color3=red
        else
            color1=red
            color2=green
            color3=blue
        end
        colors[ii]=color2
        colors[2*colorstepsOneColor-(ii-1)]=color3
        colors[2*colorstepsOneColor+ii]=color1
        colors[4*colorstepsOneColor-(ii-1)]=color3
        colors[4*colorstepsOneColor+ii]=color2
        colors[6*colorstepsOneColor-(ii-1)]=color3
    end
    return (colors,colorsteps)
end

function myimage((x,y,z,u)::Tuple{Float64, Float64, Float64, Float64},
                 radius::Float64,limit::Float64,size::Int64;
                turnIt::Tuple{Float64, Float64, Float64, Float64}=(1.0,0.0,0.0,0.0),
                 colorScheme::Int64=0,
                 colorFactor::Int64=1)::Matrix{RGB}
    image=Matrix{RGB}(UndefInitializer(),size,size)
    step = radius*2.0/convert(Float64,size)
    (colors,colorsteps) = initPalette(colorScheme=colorScheme)
    black=RGB(0.0,0.0,0.0)
    turnItNorm=normalize(turnIt)
    xpos = x-radius
    colorLimit=div(colorsteps,colorFactor)
    for i in 1:size
        ypos = y-radius
        for j in 1:size
            n=1
            c=(xpos,ypos,z,u)*turnItNorm
            v=zero(c)
            vold = v
            while true
                if norm(v)>=limit
                    image[i,j] = colors[n*colorFactor]
                    break
                end
                if n>colorLimit-1
                    image[i,j] = black
                    break
                end
                n += 1
                vtemp = v
                v = v * v - (v ⋅ v)*vold + c
                vold = vtemp
            end
            ypos += step
        end
        xpos += step
    end
    return image
end

function mydraw(fn::String,
                a::Tuple{Float64, Float64, Float64, Float64},
                radius::Float64,limit::Float64,size::Int64;
                turnIt::Tuple{Float64, Float64, Float64, Float64}=(1.0,0.0,0.0,0.0),
                colorScheme::Int64=0,
                colorFactor::Int64=1)
    image=myimage(a,radius,limit,size,
                  turnIt=turnIt,colorScheme=colorScheme,colorFactor=colorFactor)
    save(fn,image)
end
