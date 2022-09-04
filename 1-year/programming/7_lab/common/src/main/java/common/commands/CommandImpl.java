package common.commands;

import common.collection.CollectionManagerImpl;
import common.collectionexceptions.CollectionException;
import javax.validation.constraints.NotNull;

public interface CommandImpl {
    String execute(@NotNull CollectionManagerImpl collectionManager, Object[] args, String username) throws CollectionException;
}
