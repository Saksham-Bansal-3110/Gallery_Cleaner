with open("Gallery Cleaner/Views/CategoryDetailView.swift", "r") as f:
    content = f.read()

bad_string = """    var sortedDisplayStyle: CategoryDisplayStyle {
        switch sortedDisplayStyle {"""
good_string = """    var sortedDisplayStyle: CategoryDisplayStyle {
        switch displayStyle {"""

content = content.replace(bad_string, good_string)

with open("Gallery Cleaner/Views/CategoryDetailView.swift", "w") as f:
    f.write(content)
