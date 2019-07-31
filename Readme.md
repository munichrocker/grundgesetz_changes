# 70 Jahre Grundgesetz

This repo provides the data to make a section-by-section comparison between different versions of the German Grundgesetz ("basic law"). It was used to generate the article ["Wie sich das Grundgesetz in 70 Jahren verändert hat"](https://www.sueddeutsche.de/politik/grundgesetz-aenderungen-grafikanalyse-1.4429949) at Sueddeutsche Zeitung, ceberating the Grundgesetz's 70th anniversary in 2019.

### tl;dr

> Get the data for the two versions from the [grundgesetz-dev](https://github.com/c3e/grundgesetz-dev) repo, then use the Markdown version below, after that run `analyze_text.R`.

## The data

Can be accessed via the [grundgesetz-dev](https://github.com/c3e/grundgesetz-dev) repo, which aims to document all changes to the original text in a version control system.

Plus: they provide multiple output formats, like txt and markdown (as used below).

## Usage for wdiff

You simple use the Command line tool `wdiff` to compare the first GG version to the current one. To make it easier for the tool, you could add the Artikel by hand, that were added between the two versions.

`wdiff -i gg_1949_added.txt gg_2019.txt > wdiff_49_12_complete.txt`

As an alternative you could use the very good [Diff Match Patch Implementation](https://neil.fraser.name/software/diff_match_patch/demos/diff.html) by Neil Fraser and parse the result.

Then you could use the `parse_text_wdiff.R` skript to generate a dataframe that can then be used with the `analyze_text.R` skript to calculate the changes.

**Caution:** As I switched to the markdown version later in the project, I didn't maintain the wdiff-script. It runs, but not perfectly, some parts of the change-extraction still fail.

##  Using Markdown

For using the `parse_text_markdown.R` script you'll need the two version for comparison already downloaded. The script takes the two versions of every section in the Grundgesetz and compares them with a _wdiff_. This results in the best comparison, I could find.

The script returns a dataframe `d_complete` which can be saved as `parsed_gg.RData` and processed with `analyze_text.R`.

## Analysing the processed texts

No matter which approach you choose before - the script `analyze_text.R` should run fine in both cases. It calculates the shares of the text that was added and removed (which is marked by _wdiff_ as `{+ +}` and `[- -]`) as `char_added`, `char_removed` and `char_unchanged`. And it already plots some ggplots.

## Authors

[Benedict Witzenberger](mailto:b.witzenberger@googlemail.com) - Initial work, programming

Thanks to [Benjamin Heisig](https://github.com/bheisig) for his help with the Grundgesetz data.

## License

This project is licensed under the MIT License.