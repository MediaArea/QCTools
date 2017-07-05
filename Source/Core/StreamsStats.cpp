#include "Core/StreamsStats.h"

extern "C"
{
#ifndef INT64_C
#define INT64_C(c) (c ## LL)
#define UINT64_C(c) (c ## ULL)
#endif

#include <libavutil/rational.h>
#include <libavutil/avutil.h>
#include <libavformat/avformat.h>
}

#include "tinyxml2.h"
#include <sstream>
#include <iomanip>
#include <cstdlib>
#include <cfloat>
#include <cassert>
#include <string>
#include <list>
#include <QString>
#include <QDebug>
#include <QXmlStreamWriter>

#include "Core/VideoStreamStats.h"
#include "Core/AudioStreamStats.h"

using namespace tinyxml2;

StreamsStats::StreamsStats(AVFormatContext *context)
{
    if(context != NULL)
    {
        for (size_t pos = 0; pos < context->nb_streams; ++pos)
        {
            switch (context->streams[pos]->codec->codec_type)
            {
                case AVMEDIA_TYPE_VIDEO:
                    streams.push_back(new VideoStreamStats(context->streams[pos], context));
                    break;
                case AVMEDIA_TYPE_AUDIO:
                    streams.push_back(new AudioStreamStats(context->streams[pos], context));
                    break;
                default:
                    qDebug() << "only Audio / Video streams are supported for now.. skipping stream of index = " << pos << " and of type = " << context->streams[pos]->codec->codec_type;
            }
        }
    }
}

StreamsStats::~StreamsStats()
{
    for(std::list<CommonStreamStatsPtr>::const_iterator it = streams.begin(); it != streams.end(); ++it)
    {
        delete (*it);
    }
}

bool StreamsStats::readFromXML(const char *data, size_t size)
{
    XMLDocument Document;
    if (Document.Parse(data, size))
       return false;

    XMLElement* rootElement = Document.FirstChildElement("ffprobe:ffprobe");
    if (rootElement)
    {
        XMLElement* streamsElement = rootElement->FirstChildElement("streams");
        if (streamsElement)
        {
            XMLElement* streamElement = streamsElement->FirstChildElement("stream");
            while(streamElement)
            {
                const char* codec_type = streamElement->Attribute("codec_type");
                if(codec_type)
                {
                    if(strcmp(codec_type, "video") == 0)
                        streams.push_back(new VideoStreamStats(streamElement));
                    else if(strcmp(codec_type, "audio") == 0)
                        streams.push_back(new AudioStreamStats(streamElement));
                }

                streamElement = streamElement->NextSiblingElement();
            }
        }
    }

    return true;
}

void StreamsStats::writeToXML(QXmlStreamWriter *writer)
{
    writer->writeStartElement("streams");
    for(std::list<CommonStreamStatsPtr>::const_iterator it = streams.begin(); it != streams.end(); ++it)
    {
        (*it)->writeToXML(writer);
    }
    writer->writeEndElement();

}
