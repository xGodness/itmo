package client;

import common.IO.IOManager;
import common.fileexceptions.FilePermissionException;
import common.fileexceptions.InvalidFileNameException;

import java.io.File;
import java.io.FileNotFoundException;

public class ClientFileManager {

    private final IOManager ioManager;

    public ClientFileManager(IOManager ioManager) {
        this.ioManager = ioManager;
    }

    public File openFile(String fileName) throws InvalidFileNameException, FilePermissionException, FileNotFoundException {
        if (!ioManager.isStringValid(fileName)) {
            throw new InvalidFileNameException("File name is invalid");
        }
        File file = new File(fileName);
        if (!file.exists()) {
            throw new FileNotFoundException("File with such name was not found");
        }
        if (!file.canRead()) {
            throw new FilePermissionException("You do not have permission to read this file");
        }
        return file;

    }
}
