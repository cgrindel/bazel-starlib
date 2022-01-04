def _create(letter):
    return struct(
        letter = letter,
        src = letter + ".txt",
        out = letter + ".txt_modified",
        src_name = letter + "_src",
        out_name = letter + "_out",
    )

letters = struct(
    create = _create,
)
