# The Main File
load "package.ring"
load "lib.ring"
load "src/utils/color.ring"

func main
    # Auto-size to fit the longest content line
    cDesc = aPackageInfo[:description]
    nMinWidth = max([ len(cDesc) + 4, 47 ])
    nInnerWidth = nMinWidth
    cHLine = copy("─", nInnerWidth)

    # Reusable border + empty line
    border  = colorText([:text = "│", :color = :BRIGHT_BLUE])
    emptyLn = border + colorText([:text = space(nInnerWidth), :color = :BRIGHT_BLUE]) + border

    banner = []

    # Top border
    banner[:topBorder] = colorText([:text = "╭" + cHLine + "╮", :color = :BRIGHT_BLUE, :style = :BOLD])
    banner[:tEmpty1]   = emptyLn

    # Title: ★ Ring Python ★
    cName = aPackageInfo[:name]
    banner[:titleLine] = centeredLine(nInnerWidth,
        colorText([:text = cSymbols[:STAR] + " " + cName + " " + cSymbols[:STAR], :color = :CYAN, :style = :BOLD]),
        2 + 2 + len(cName))

    banner[:tEmpty2] = emptyLn

    # Version
    cVersionStr = "v" + aPackageInfo[:version]
    banner[:versionLine] = centeredLine(nInnerWidth,
        colorText([:text = cVersionStr, :color = :YELLOW, :style = :BOLD]),
        len(cVersionStr))

    # Description
    banner[:tEmpty3] = emptyLn
    banner[:descLine] = centeredLine(nInnerWidth,
        colorText([:text = cDesc, :color = :WHITE, :style = :DIM]),
        len(cDesc))

    banner[:tEmpty4] = emptyLn

    # Separator
    nSepPad = 5
    nDotsCount = nInnerWidth - (nSepPad * 2)
    banner[:separator] = colorText([:text = "│" + space(nSepPad), :color = :BRIGHT_BLUE]) +
                         colorText([:text = copy("·", nDotsCount), :color = :WHITE, :style = :DIM]) +
                         colorText([:text = space(nSepPad) + "│", :color = :BRIGHT_BLUE])

    banner[:bEmpty5] = emptyLn

    # Author: Made with ♥ by ysdragon
    cAuthorText = "Made with  by ysdragon"
    nAuthorVisualWidth = len(cAuthorText) + 1
    nAuthorPad = floor((nInnerWidth - nAuthorVisualWidth) / 2)
    nAuthorPadRight = nInnerWidth - nAuthorVisualWidth - nAuthorPad
    banner[:authorLine] = colorText([:text = "│" + space(nAuthorPad), :color = :BRIGHT_BLUE]) +
                          colorText([:text = "Made with ", :color = :WHITE, :style = :DIM]) +
                          colorText([:text = cSymbols[:HEART], :color = :BRIGHT_RED]) +
                          colorText([:text = " by ", :color = :WHITE, :style = :DIM]) +
                          colorText([:text = "ysdragon", :color = :MAGENTA]) +
                          colorText([:text = space(nAuthorPadRight) + "│", :color = :BRIGHT_BLUE])

    banner[:bEmpty6] = emptyLn

    # URL
    cUrlStr = "https://github.com/ysdragon"
    banner[:urlLine] = centeredLine(nInnerWidth,
        colorText([:text = cUrlStr, :color = :GREEN, :style = :UNDERLINE]),
        len(cUrlStr))

    banner[:bEmpty7] = emptyLn

    # Bottom border
    banner[:bottomBorder] = colorText([:text = "╰" + cHLine + "╯", :color = :BRIGHT_BLUE, :style = :BOLD])

    # Print
    ? ""
    for line in banner
        ? "  " + line[2]
    next
    ? ""

# Build a centered line inside the box border
func centeredLine nWidth, cContent, nVisualLen
    nPadLeft  = floor((nWidth - nVisualLen) / 2)
    nPadRight = nWidth - nVisualLen - nPadLeft
    return colorText([:text = "│" + space(nPadLeft), :color = :BRIGHT_BLUE]) +
           cContent +
           colorText([:text = space(nPadRight) + "│", :color = :BRIGHT_BLUE])
