#!/usr/bin/sh

scriptDir="$(realpath --canonicalize-missing "$0/..")"

regenHTML="$1"

ebuildHTML="$scriptDir/ebuild-vars.html"

endingTagSearch=false
{
    [ ! -f "$ebuildHTML" ] || [ "$regenHTML" = true ]
} &&
curl --silent 'https://devmanual.gentoo.org/ebuild-writing/variables/index.html' > "$ebuildHTML"

echo "return [[" > "$scriptDir/ebuild-vars.lua"

while IFS='' read -r line; do
    $endingTagSearch && {
        case "$line" in
            '</table>')
                endingTagSearch=false
                ;;
            *)
                echo "$line"
                ;;
        esac
        } || {
        case "$line" in
            '<h2 id="predefined-read-only-variables">'*)
                echo "$line"
                endingTagSearch=true
                ;;
            '<h2 id="ebuild-defined-variables">'*)
                echo "$line"
                endingTagSearch=true
                ;;
            '<h2 id="user-environment">'*)
                echo "$line"
                endingTagSearch=true
                ;;
        esac
    }
done < "$ebuildHTML" |
sed -nE 's|^\s*<td><code class="docutils literal"><span class="pre">([A-Z][^<]*)</span></code></td>$|export \1|p' >> "$scriptDir/ebuild-vars.lua"

eclassParse(){
    eclassHTML="$scriptDir/$1-eclass.html"

    endingTagSearch=false
    {
        [ ! -f "$eclassHTML" ] || [ "$regenHTML" = true ]
    } &&
    curl --silent "https://devmanual.gentoo.org/eclass-reference/$1.eclass/index.html" > "$eclassHTML"

    while IFS='' read -r line; do
        $endingTagSearch && {
            case "$line" in
                '<H2'*)
                    endingTagSearch=false
                    ;;
                *)
                    echo "$line"
                    ;;
            esac
            } || {
            case "$line" in
                '<H2 ID="'*'">ECLASS VARIABLES</H2>')
                    echo "$line"
                    endingTagSearch=true
                    ;;
            esac
        }
    done < "$eclassHTML" |
    sed -nE 's|^<DT><B>([^<]*)<.+|export \1|p' >> "$scriptDir/ebuild-vars.lua"
}

eclassGroupsHTML="$scriptDir/eclass-list.html"

endingTagSearch=false
{
    [ ! -f "$eclassGroupsHTML" ] || [ "$regenHTML" = true ]
} &&
curl --silent "https://devmanual.gentoo.org/eclass-reference/index.html" > "$eclassGroupsHTML"

sed -nE 's|<li class="list-group-item"><a href="([^"]+)\.eclass.*|\1|p' "$eclassGroupsHTML" | while IFS='' read -r eclass; do
    eclassParse "$eclass"
done

echo "]]" >> "$scriptDir/ebuild-vars.lua"

sed -i -E '/^export .*[&;].*/d' "$scriptDir/ebuild-vars.lua"
