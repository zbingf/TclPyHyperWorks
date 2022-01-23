
import tkinter.filedialog

fem_paths = tkinter.filedialog.askopenfilenames(
	filetypes = (('h3d', '*.h3d'),),
	)

print(' '.join(fem_paths))

