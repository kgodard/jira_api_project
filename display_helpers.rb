module DisplayHelpers

  def truncpad(el, len = 30)
    trunc(el.to_s, len).ljust(len)
  end

  def trunc(txt, chars)
    dotdot = txt.length > chars ? '...' : ''
    txt[0,chars - dotdot.length] + dotdot
  end

  def separator
    ' | '
  end
end
