return {
    s('date', c(1, {
        t(os.date('%Y%m%d')),
        t(os.date('%Y-%m-%d %H:%M:%S')),
    })),

    s('zqspb', fmt('{}{}', {
        c(1, { t('// '), t('-- '), t('') }),
        d(2, function(args)
            local comment = args[1][1] or ''
            if comment == '' then
                return sn(nil, { t('ZQSPB-'), i(1, 'TODO'), t(', name:edit, '), i(0) })
            end
            return sn(nil, { t('ZQSPB-'), i(1, 'TODO'), t(', name, '), t(os.date('%Y%m%d')), t(', '), i(0) })
        end, { 1 }),
    })),
}
