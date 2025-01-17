"""
    contourplot(x, y, A; kw...)

Draws a contour plot on a new canvas.

# Usage

    contourplot(x, y, A; $(keywords(; add = (Z_DESCRIPTION..., :canvas), remove = (:blend, :grid))))

# Arguments

$(arguments(
    (
        A = "`Matrix` of interest for which contours are extracted, or `Function` evaluated as `f(x, y)`",
        levels = "the number of contour levels",
    ); add = (Z_DESCRIPTION..., :canvas), remove = (:blend, :grid)
))

# Author(s)

- T Bltg (github.com/t-bltg)

# Examples

```julia-repl
julia> contourplot(-1:.1:1, -1:.1:1, (x, y) -> √(x^2 + y^2))
      ┌────────────────────────────────────────┐  ⠀⠀⠀⠀  
    1 │⠀⠀⠀⠀⠀⠀⠀⠀⣀⠤⠒⠊⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠒⠢⣄⡀⠀⠀⠀⠀⠀⠀⠀│  ┌──┐ 1
      │⠀⠀⠀⠀⠀⡠⠔⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠱⠤⡀⠀⠀⠀⠀│  │▄▄│  
      │⠀⠀⠀⡰⠊⠀⠀⠀⠀⠀⠀⠀⠀⣀⠤⠔⠒⠒⠉⠉⠉⠉⠓⠒⠒⠤⣄⠀⠀⠀⠀⠀⠀⠀⠀⠘⠢⡀⠀⠀│  │▄▄│  
      │⠀⡰⠉⠀⠀⠀⠀⠀⠀⢀⡠⠒⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠑⠢⡀⠀⠀⠀⠀⠀⠀⠑⢆⠀│  │▄▄│  
      │⡜⠀⠀⠀⠀⠀⠀⢀⠔⠁⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠈⠢⡄⠀⠀⠀⠀⠀⠀⢣│  │▄▄│  
      │⠀⠀⠀⠀⠀⠀⢠⠃⠀⠀⠀⠀⠀⠀⢀⠔⠊⠁⠀⠀⠀⠀⠈⠙⠢⢄⠀⠀⠀⠀⠀⠀⠑⡄⠀⠀⠀⠀⠀⠀│  │▄▄│  
      │⠀⠀⠀⠀⠀⢀⠇⠀⠀⠀⠀⠀⠀⡰⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢣⠀⠀⠀⠀⠀⠀⢘⡄⠀⠀⠀⠀⠀│  │▄▄│  
      │⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠠⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢘⠄⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀│  │▄▄│  
      │⠀⠀⠀⠀⠀⠘⡆⠀⠀⠀⠀⠀⠀⠣⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡜⠀⠀⠀⠀⠀⠀⢠⠃⠀⠀⠀⠀⠀│  │▄▄│  
      │⠀⠀⠀⠀⠀⠀⠱⡀⠀⠀⠀⠀⠀⠀⠉⠒⣄⣀⠀⠀⠀⠀⢀⣀⠔⠉⠀⠀⠀⠀⠀⠀⢀⠎⠀⠀⠀⠀⠀⠀│  │▄▄│  
      │⢇⠀⠀⠀⠀⠀⠀⠘⠦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⡠⠃⠀⠀⠀⠀⠀⠀⡰│  │▄▄│  
      │⠈⠢⡀⠀⠀⠀⠀⠀⠀⠈⠒⠤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⠔⠋⠀⠀⠀⠀⠀⠀⢀⠖⠁│  │▄▄│  
      │⠀⠀⠈⠱⣀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠒⠢⠤⢤⣀⣀⣀⣀⡠⠤⠤⠒⠊⠁⠀⠀⠀⠀⠀⠀⠀⢀⠔⠁⠀⠀│  │▄▄│  
      │⠀⠀⠀⠀⠀⠑⠦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⠒⠁⠀⠀⠀⠀│  │▄▄│  
   -1 │⠀⠀⠀⠀⠀⠀⠀⠀⠙⠒⠤⢄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⠤⠔⠊⠁⠀⠀⠀⠀⠀⠀⠀│  └──┘ 0
      └────────────────────────────────────────┘  ⠀⠀⠀⠀  
      ⠀-1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀1⠀  ⠀⠀⠀⠀  
```

"""
function contourplot(
    x::AbstractVector,
    y::AbstractVector,
    A::Union{Function,AbstractMatrix};
    canvas::Type = BrailleCanvas,
    name::AbstractString = KEYWORDS.name,
    levels::Integer = 3,
    colormap = KEYWORDS.colormap,
    blend = false,
    grid = false,
    colorbar = true,
    kw...,
)
    callback = colormap_callback(colormap)
    plot = Plot(
        extrema(x) |> collect,
        extrema(y) |> collect,
        canvas;
        blend = blend,
        grid = grid,
        colorbar = colorbar,
        colormap = callback,
        kw...,
    )
    if A isa Function
        X = repeat(x', length(y), 1)
        Y = repeat(y, 1, length(x))
        A = map(A, X, Y) |> Matrix
    end
    contourplot!(plot, x, y, A; name = name, levels = levels, colormap = callback)
end

function contourplot!(
    plot::Plot{<:Canvas},
    x::AbstractVector,
    y::AbstractVector,
    A::AbstractMatrix;
    name::AbstractString = "",
    levels::Integer = 3,
    colormap = :viridis,
)
    name == "" || label!(plot, :r, string(name))

    plot.colormap = callback = colormap_callback(colormap)
    mA, MA = extrema(A)

    for cl in Contour.levels(Contour.contours(y, x, A, levels))
        color = callback(Contour.level(cl), mA, MA)
        for line in Contour.lines(cl)
            yi, xi = Contour.coordinates(line)
            lineplot!(plot, xi, yi, color = color)
        end
    end
    plot
end

"""
    contourplot(A; kw...)

Draws a contour plot of matrix `A` along axis `x` and `y` on a new canvas.

The `y` axis is flipped by default:

```
Julia matrices (images) │ UnicodePlots
                        │
           axes(A, 2)   │
           o───────→    │   ↑
           │            │   │
axes(A, 1) │            │ y │
           │            │   │
           ↓            │   o───────→
                        │       x
```
"""
contourplot(A::AbstractMatrix; kw...) =
    contourplot(axes(A, 2) |> collect, axes(A, 1) |> reverse |> collect, A; kw...)
