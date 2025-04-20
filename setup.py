from setuptools import setup
import os

# Convenience function for reading information files
def read(f_name, empty_lines=False):
    text = []
    with open(os.path.join(package_about, f_name)) as f:
        for line in f:
            line = line.strip("\n")
            if (not empty_lines) and (len(line.strip()) == 0): continue
            if (len(line) > 0) and (line[0] == "%"): continue
            text.append(line)
    return text

# Package information
package_name = "Claude"
package = "macos_claude_overlay"
package_about = os.path.join(os.path.dirname(os.path.abspath(__file__)), "macos_gemini_overlay", "about")

# Read package information
version = read("version.txt")[0]
description = read("description.txt")[0]
keywords = read("keywords.txt")
classifiers = read("classifiers.txt")
name, email, git_username = read("author.txt")
requirements = read("requirements.txt")

setup(
    author = name,
    author_email = email,
    name = package,
    packages = [package],
    package_data = {
        package: ["logo/logo_white.png", "logo/logo_black.png", "about/*"],
    },
    include_package_data = True,
    install_requires = requirements,
    version = version,
    url = f'https://github.com/{git_username}/{package}',
    description = description,
    keywords = keywords,
    python_requires = '>=3.10',
    license = 'MIT',
    classifiers = classifiers
)
