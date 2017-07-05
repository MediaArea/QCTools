/*  Copyright (c) BAVC. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license that can
 *  be found in the License.html file in the root of the source tree.
 */

//---------------------------------------------------------------------------
#ifndef Preferences_H
#define Preferences_H
//---------------------------------------------------------------------------

#include "Core/Core.h"

#include <QMetaType>
#include <QObject>
#include <QPair>
#include <QList>

typedef QPair<int, int> GroupAndType;
typedef QList<GroupAndType> FilterSelectorsOrder;

class Preferences : public QObject
{
public:
    Preferences(QObject* parent = NULL);

    activefilters activeFilters() const;
    void setActiveFilters(const activefilters& filters);

    activealltracks activeAllTracks() const;
    void setActiveAllTracks(const activealltracks& alltracks);

    FilterSelectorsOrder loadFilterSelectorsOrder();
    void saveFilterSelectorsOrder(const FilterSelectorsOrder& order);

    bool isSignalServerEnabled() const;
    void setSignalServerEnabled(bool enabled);

    bool isSignalServerAutoUploadEnabled() const;
    void setSignalServerAutoUploadEnabled(bool enabled);

    QString signalServerUrlString() const;
    void setSignalServerUrlString(const QString & urlString);

    QString signalServerLogin() const;
    void setSignalServerLogin(const QString& login);

    QString signalServerPassword() const;
    void setSignalServerPassword(const QString& password);

    void sync();
};

Q_DECLARE_METATYPE(GroupAndType)
Q_DECLARE_METATYPE(FilterSelectorsOrder)

#endif // Preferences_H
