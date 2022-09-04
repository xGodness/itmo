package lab5.commands;

import lab5.exceptions.collection_exceptions.CollectionException;

public interface CommandImpl {
    String execute(String[] args) throws CollectionException;
}
