" vim600: set foldmethod=marker:
"
" Maintainer: Felipe Contreras <felipe.contreras@gmail.com>
"
" Section: Documentation {{{1
" 
" This script converts the guifg/guibg parameters of a colorscheme the
" equivalent cterm ones for 256-color terminals.
"
" It's a rewrite from Shawn Biddle's script that uses PHP:
" http://shawnbiddle.com/toCterm
"
" Simply run :source <path_to_this_script>.vim

" Section: Script {{{1

function! Hex2Sgr(color)
ruby <<EOF
  $basic = [
    [0x00, 0x00, 0x00],
    [0xcd, 0x00, 0x00],
    [0x00, 0xcd, 0x00],
    [0xcd, 0xcd, 0x00],
    [0x00, 0x00, 0xee],
    [0xcd, 0x00, 0xcd],
    [0x00, 0xcd, 0xcd],
    [0xe5, 0xe5, 0xe5],
    [0x7f, 0x7f, 0x7f],
    [0xff, 0x00, 0x00],
    [0x00, 0xff, 0x00],
    [0xff, 0xff, 0x00],
    [0x5c, 0x5c, 0xff],
    [0xff, 0x00, 0xff],
    [0x00, 0xff, 0xff],
    [0xff, 0xff, 0xff],
  ]

  $valuerange = [0x00, 0x5f, 0x87, 0xaf, 0xd7, 0xff]

  def xterm2rgb(c)
    case c
    when 0..15
      $basic[c]
    when 16..232
      c -= 16
      [c / 36, c / 6, c].map { |e| $valuerange[e % 6] }
    when 233..253
      [(8 + (c - 232) * 10)] * 3
    end
  end

  def maketable
    $colortable = []
    (0..253).each do |c|
      $colortable[c] = xterm2rgb(c)
    end
  end

  def hex2sgr(color)
    best_match = 0
    smallest_distance = 10000000000.0

    color = color.chars.map { |e| e * 2 }.join if color.size == 3

    rgb = color.scan(/../).map { |e| e.to_i(16) }

    (0..253).each do |c|
      d = ($colortable[c][0] - rgb[0]) ** 2 + ($colortable[c][1] - rgb[1]) ** 2 + ($colortable[c][2] - rgb[2]) ** 2
      if (d < smallest_distance)
	smallest_distance = d
	best_match = c
      end
    end

    return best_match
  end

  maketable
  color = VIM::evaluate('a:color')
  VIM::command(%[return "%s"] % hex2sgr(color))
EOF
endfunction

:%s/\vgui(bg|fg)\=#(\S+)\zs%( cterm%(bg|fg)\=%(\S+))?( |$)/\=" cterm".submatch(1)."=".Hex2Sgr(submatch(2)).submatch(3)/g
