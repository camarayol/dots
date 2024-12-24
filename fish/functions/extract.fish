function extract
    set remove_archive 1

    if test (count $argv) -eq 0
        echo "Usage: extract [-option] [file ...]"
        echo "Options:"
        echo "    -r, --remove      Remove archive after unpacking."
        return 1
    end

    if test "$argv[1]" = "-r" -o "$argv[1]" = "--remove"
        set remove_archive 0
        set argv (commandline --cut-at-cursor --current-process)
    end

    for file in $argv
        if not test -f $file
            echo "extract: '$file' is not a valid file" >&2
            continue
        end

        set extract_dir (basename $file | sed -E 's/\.[^.]+$//')
        set success 0

        switch (string lower $file)
            case '*.tar.gz' '*.tgz'
                if command -v pigz > /dev/null
                    pigz -dc $file | tar xv
                else
                    tar zxvf $file
                end
            case '*.tar.bz2' '*.tbz' '*.tbz2'
                tar xvjf $file
            case '*.tar.xz' '*.txz'
                if tar --xz --help ^/dev/null
                    tar --xz -xvf $file
                else
                    xzcat $file | tar xvf -
                end
            case '*.tar.zma' '*.tlz'
                if tar --lzma --help ^/dev/null
                    tar --lzma -xvf $file
                else
                    lzcat $file | tar xvf -
                end
            case '*.tar.zst' '*.tzst'
                if tar --zstd --help ^/dev/null
                    tar --zstd -xvf $file
                else
                    zstdcat $file | tar xvf -
                end
            case '*.tar'
                tar xvf $file
            case '*.tar.lz'
                if command -v lzip > /dev/null
                    tar xvf $file
                else
                    echo "extract: lzip is required to extract '$file'" >&2
                    set success 1
                end
            case '*.gz'
                if command -v pigz > /dev/null
                    pigz -dk $file
                else
                    gunzip -k $file
                end
            case '*.bz2'
                bunzip2 $file
            case '*.xz'
                unxz $file
            case '*.lzma'
                unlzma $file
            case '*.z'
                uncompress $file
            case '*.zip' '*.war' '*.jar' '*.sublime-package' '*.ipsw' '*.xpi' '*.apk' '*.aar' '*.whl'
                mkdir -p $extract_dir
                unzip $file -d $extract_dir
            case '*.rar'
                unrar x -ad -o+ $file
            case '*.rpm'
                mkdir -p $extract_dir
                pushd $extract_dir
                rpm2cpio ../$file | cpio --quiet -id
                popd
            case '*.7z'
                7za x -y $file
            case '*.deb'
                mkdir -p "$extract_dir/control" "$extract_dir/data"
                pushd $extract_dir
                ar vx "../$file" > /dev/null
                pushd control
                tar xzvf ../control.tar.gz
                popd
                pushd data
                extract ../data.tar.*
                popd
                rm *.tar.* debian-binary
                popd
            case '*.zst'
                unzstd $file
            case '*'
                echo "extract: '$file' cannot be extracted" >&2
                set success 1
        end

        if test $success -eq 0 -a $remove_archive -eq 0
            rm $file
        end
    end
end

