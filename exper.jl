#  Steffen Zahn

import Base.+
import Base.-
import Base.*
import Base./
import Base.zero
import Base.iszero
import Base.one
import Base.inv
import Base.isnan
using Images
using ColorTypes

function zero(a::Tuple{Float64, Float64, Float64, Float64}
              )::Tuple{Float64, Float64, Float64, Float64}
    return (0.0,0.0,0.0,0.0)
end
function iszero((x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64}
              )::Bool
    return x1==0.0 && x2==0.0 && x3==0.0 && x4==0.0
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

function isnan((x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64}
               )::Bool
    return isnan(x1) || isnan(x2) || isnan(x3) || isnan(x4) 
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

# wrong multiplication
function funnyMultiply((x1,x2,x3,x4)::Tuple{Float64, Float64, Float64, Float64},
           (y1,y2,y3,y4)::Tuple{Float64, Float64, Float64, Float64}
           )::Tuple{Float64, Float64, Float64, Float64}
     return (x1*y1-x2*y2-x3*y3-x4*y4,
             x2*y1+x1*y2+x3*y4+x4*y3,
             x3*y1+x1*y3+x2*y4+x4*y2,
             x1*y4+x4*y1+x2*y3+x3*y2)
end

function initPalette(;colorScheme::Int64=0,
                     colorRepetitions::Int64=1)::Tuple{Vector{RGB},Int64}
    colorSet=0
    if colorScheme>=6
        colorSet=1
        colorScheme -= 6
    end
    colorstepsOneColor=256
    colorsteps=6*colorRepetitions*colorstepsOneColor
    gray = 1.0/convert(Float64,colorstepsOneColor)
    colors=Array{RGB}(UndefInitializer(),colorsteps)
    for ii in 1:colorstepsOneColor
        scaledGray=gray*ii
        baseColor1=RGB(0.0,0.0,0.0)
        baseColor2=baseColor1
        baseColor3=baseColor1
        if colorSet == 0
            baseColor1=RGB(scaledGray,0.0,0.7*scaledGray)
            baseColor2=RGB(0.0,scaledGray,0.8*scaledGray)
            baseColor3=RGB(0.4*scaledGray,0.0,scaledGray)
        else
            baseColor1=RGB(scaledGray,0.0,0.4*scaledGray)
            baseColor2=RGB(0.635294*scaledGray,scaledGray,0.0)
            baseColor3=RGB(0.0,0.815686*scaledGray,scaledGray)
        end
        if colorScheme == 1
            color1=baseColor3
            color2=baseColor1
            color3=baseColor2
        elseif colorScheme == 2
            color1=baseColor2
            color2=baseColor3
            color3=baseColor1
        elseif colorScheme == 3
            color1=baseColor3
            color2=baseColor2
            color3=baseColor1
        elseif colorScheme == 4
            color1=baseColor2
            color2=baseColor1
            color3=baseColor3
        elseif colorScheme == 5
            color1=baseColor1
            color2=baseColor3
            color3=baseColor2
        else
            color1=baseColor1
            color2=baseColor2
            color3=baseColor3
        end
        for jj in 0:colorRepetitions-1
            colors[jj*6*colorstepsOneColor+ii]=color2
            colors[(jj*6+2)*colorstepsOneColor-(ii-1)]=color2
            colors[(jj*6+2)*colorstepsOneColor+ii]=color1
            colors[(jj*6+4)*colorstepsOneColor-(ii-1)]=color1
            colors[(jj*6+4)*colorstepsOneColor+ii]=color3
            colors[(jj*6+6)*colorstepsOneColor-(ii-1)]=color3
        end
    end
    return (colors,colorsteps)
end

function myimage((x,y,z,u)::Tuple{Float64, Float64, Float64, Float64},
                 radius::Float64,limit::Float64,size::Int64;
                 turnIt::Tuple{Float64, Float64, Float64, Float64}=(1.0,0.0,0.0,0.0),
                 colorScheme::Int64=0,
                 colorFactor::Int64=1,
                 colorOffset::Int64=0,
                 colorRepetitions::Int64=1,
                 discrete::Bool=false)::Matrix{RGB}
    image=Matrix{RGB}(UndefInitializer(),size,size)
    step = radius*2.0/convert(Float64,size)
    (colors,colorsteps) = initPalette(colorScheme=colorScheme,colorRepetitions=colorRepetitions)
    black=RGB(0.0,0.0,0.0)
    turnItNorm=normalize(turnIt)
    xpos = x-radius
    colorLimit=div(colorsteps-colorOffset,colorFactor)
    for i in 1:size
        ypos = y-radius
        for j in 1:size
            n=1
            c=((xpos,ypos,z,u)-(x,y,z,u))*turnItNorm+(x,y,z,u)
            v=zero(c)
            w=zero(c)
            vold = v
            while true
                currentNorm=norm(v)
                if currentNorm>=limit
                    if discrete
                      image[i,j] = colors[colorOffset+n*colorFactor]
                    else
                        n1 = (n - 1) * sqrt(n - 1)
                        value=1+convert(Int64,trunc((((1 + n1) * limit * (colorLimit-1))/(currentNorm+n1*limit))))
                        image[i,j] = colors[colorOffset+value*colorFactor]
                    end
                    break
                end
                if n>colorLimit-1
                    image[i,j] = black
                    break
                end
                n += 1
                vtemp = v
                v = 0.07 * funnyMultiply(v,v) + 2.3 * w + c
                w = 0.05 * funnyMultiply(w,w) - 0.3 * vtemp + c
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
                colorFactor::Int64=1,
                colorOffset::Int64=0,
                colorRepetitions::Int64=1,
                discrete::Bool=false)
    image=myimage(a,radius,limit,size,
                  turnIt=turnIt,
                  colorScheme=colorScheme,
                  colorFactor=colorFactor,
                  colorOffset=colorOffset,
                  colorRepetitions=colorRepetitions,
                  discrete=discrete)
    save(fn,image)
end

function myvideosequence()
    radius=6.6
    center=(-3.0, 0.0, 0.0, 0.0)
    angle=one(center)
    angleDeltaList=(
    normalize(inv((70.0,0.0,1.0,1.0))),
    normalize(inv((70.0,0.0,1.0,-1.0))),
    normalize(inv((70.0,0.0,-1.0,1.0))),
    normalize(inv((70.0,0.0,-1.0,-1.0))),
    normalize(inv((70.0,1.0,0.0,-1.0))),
    normalize(inv((70.0,1.0,0.0,1.0))),
    normalize(inv((70.0,1.0,-1.0,0.0))),
    normalize(inv((70.0,1.0,1.0,0.0))),
    normalize(inv((70.0,-1.0,1.0,0.0))),
    normalize(inv((70.0,-1.0,-1.0,0.0))),
    normalize(inv((70.0,-1.0,0.0,1.0))),
    normalize(inv((70.0,-1.0,0.0,-1.0)))
    )
    angleDelta=angleDeltaList[1]
    for iii in 1:700
        fn="xx_$(iii).png"
        println(iii," ",radius)
        mydraw(fn,center, radius, 1000.0, 1000,colorScheme=7,colorFactor=1,colorOffset=70,colorRepetitions=1,turnIt=angle)
        #radius=radius*0.975
        if iii % 70 == 1
            angleDelta=angleDeltaList[1 + abs(rand(Int64)) % length(angleDeltaList)]
        end
        angle = angle*angleDelta
    end

    #  ffmpeg -i xx_%d.png -c:v libx264 -b:v 6000k -pass 1 -vf scale=600:600 -b:a 128k output.mp4
    #  xffmpeg -i xx_%d.png -c:v libx264 -b:v 6000k -pass 2 -vf scale=600:600 -b:a 128k output.mp4
end
