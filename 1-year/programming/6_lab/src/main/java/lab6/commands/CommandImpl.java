package lab6.commands;

import lab6.exceptions.collectionexceptions.CollectionException;
import lab6.collection.CollectionManagerImpl;

import javax.validation.constraints.NotNull;

public interface CommandImpl {
    String execute(@NotNull CollectionManagerImpl moviesCollection, Object[] args) throws CollectionException;
}
