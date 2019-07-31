//
//  KYLQueue.h
//  yuvShowKYLDemo
//
//  Created by yulu kong on 2019/7/31.
//  Copyright © 2019 yulu kong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum {
    KYLCustomWorkQueue,
    KYLCustomFreeQueue
} KYLCustomQueueType;

typedef struct KYLCustomQueueNode {
    void    *data;
    size_t  size;  // data size
    long    index;
    struct  KYLCustomQueueNode *next;
} KYLCustomQueueNode;

typedef struct KYLCustomQueue {
    int size;
    KYLCustomQueueType type;
    KYLCustomQueueNode *front;
    KYLCustomQueueNode *rear;
} KYLCustomQueue;

class KYLQueue
{
public:
    KYLCustomQueue *m_free_queue;
    KYLCustomQueue *m_work_queue;
    
    KYLQueue();
    ~KYLQueue();
    
    // Queue Operation
    void InitQueue(KYLCustomQueue *queue,
                   KYLCustomQueueType type);
    void EnQueue(KYLCustomQueue *queue,
                 KYLCustomQueueNode *node);
    KYLCustomQueueNode *DeQueue(KYLCustomQueue *queue);
    void ClearKYLCustomQueue(KYLCustomQueue *queue);
    void FreeNode(KYLCustomQueueNode* node);
    void ResetFreeQueue(KYLCustomQueue *workQueue, KYLCustomQueue *FreeQueue);
    
private:
    pthread_mutex_t free_queue_mutex;
    pthread_mutex_t work_queue_mutex;
};


NS_ASSUME_NONNULL_END
