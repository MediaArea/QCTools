!isEqual(QT_MAJOR_VERSION, 5) {
    defineReplace(absolute_path) {
        win32:1 ~= s|\\\\|/|g

        contains(1, ^/.*):pfx = /
        else:pfx =

        segs = $$split(1, /)
        out =
        for(seg, segs) {
            equals(seg, ..):out = $$member(out, 0, -2)
            else:!equals(seg, .):out += $$seg
        }
        return($$join(out, /, $$pfx, $$2))
    }
}
