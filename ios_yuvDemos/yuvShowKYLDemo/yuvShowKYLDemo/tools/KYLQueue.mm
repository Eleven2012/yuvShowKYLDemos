//
//  KYLQueue.m
//  yuvShowKYLDemo
//
//  Created by yulu kong on 2019/7/31.
//  Copyright © 2019 yulu kong. All rights reserved.
//

#import "KYLQueue.h"
#import <pthread.h>
#include "log4cplus.h"

#pragma mark - Queue Size   设置队列的长度，不可过长
const int KYLCustomQueueSize = 3;

const static char *kModuleName = "KYLQueueProcess";

#pragma mark - Init

KYLQueue::KYLQueue(){
    m_free_queue = (KYLCustomQueue *)malloc(sizeof(struct KYLCustomQueue));
    m_work_queue = (KYLCustomQueue *)malloc(sizeof(struct KYLCustomQueue));
    
    InitQueue(m_free_queue, KYLCustomFreeQueue);
    InitQueue(m_work_queue, KYLCustomWorkQueue);
    
    for (int i = 0; i < KYLCustomQueueSize; i++) {
        KYLCustomQueueNode *node = (KYLCustomQueueNode *)malloc(sizeof(struct KYLCustomQueueNode));
        node->data = NULL;
        node->size = 0;
        node->index= 0;
        this->EnQueue(m_free_queue, node);
    }
    
    pthread_mutex_init(&free_queue_mutex, NULL);
    pthread_mutex_init(&work_queue_mutex, NULL);
    
    log4cplus_info(kModuleName, "%s: Init finish !",__func__);
}

void KYLQueue::InitQueue(KYLCustomQueue *queue, KYLCustomQueueType type) {
    if (queue != NULL) {
        queue->type  = type;
        queue->size  = 0;
        queue->front = 0;
        queue->rear  = 0;
    }
}

#pragma mark - Main Operation
void KYLQueue::EnQueue(KYLCustomQueue *queue, KYLCustomQueueNode *node) {
    if (queue == NULL) {
        log4cplus_debug(kModuleName, "%s: current queue is NULL",__func__);
        return;
    }
    
    if (node==NULL) {
        log4cplus_debug(kModuleName, "%s: current node is NUL",__func__);
        return;
    }
    
    node->next = NULL;
    
    if (KYLCustomFreeQueue == queue->type) {
        pthread_mutex_lock(&free_queue_mutex);
        
        if (queue->front == NULL) {
            queue->front = node;
            queue->rear  = node;
        }else {
            /*
             // tail in,head out
             freeQueue->rear->next = node;
             freeQueue->rear = node;
             */
            
            // head in,head out
            node->next = queue->front;
            queue->front = node;
        }
        queue->size += 1;
        log4cplus_debug(kModuleName, "%s: free queue size=%d",__func__,queue->size);
        pthread_mutex_unlock(&free_queue_mutex);
    }
    
    if (KYLCustomWorkQueue == queue->type) {
        pthread_mutex_lock(&work_queue_mutex);
        //TODO
        static long nodeIndex = 0;
        node->index=(++nodeIndex);
        if (queue->front == NULL) {
            queue->front = node;
            queue->rear  = node;
        }else {
            queue->rear->next   = node;
            queue->rear         = node;
        }
        queue->size += 1;
        log4cplus_debug(kModuleName, "%s: work queue size=%d",__func__,queue->size);
        pthread_mutex_unlock(&work_queue_mutex);
    }
}

KYLCustomQueueNode* KYLQueue::DeQueue(KYLCustomQueue *queue) {
    if (queue == NULL) {
        log4cplus_debug(kModuleName, "%s: current queue is NULL",__func__);
        return NULL;
    }
    
    const char *type = queue->type == KYLCustomWorkQueue ? "work queue" : "free queue";
    pthread_mutex_t *queue_mutex = ((queue->type == KYLCustomWorkQueue) ? &work_queue_mutex : &free_queue_mutex);
    KYLCustomQueueNode *element = NULL;
    
    pthread_mutex_lock(queue_mutex);
    element = queue->front;
    if(element == NULL) {
        pthread_mutex_unlock(queue_mutex);
        log4cplus_debug(kModuleName, "%s: The node is NULL",__func__);
        return NULL;
    }
    
    queue->front = queue->front->next;
    queue->size -= 1;
    pthread_mutex_unlock(queue_mutex);
    
    log4cplus_debug(kModuleName, "%s: type=%s size=%d",__func__,type,queue->size);
    return element;
}

void KYLQueue::ResetFreeQueue(KYLCustomQueue *workQueue, KYLCustomQueue *freeQueue) {
    if (workQueue == NULL) {
        log4cplus_debug(kModuleName, "%s: The WorkQueue is NULL",__func__);
        return;
    }
    
    if (freeQueue == NULL) {
        log4cplus_debug(kModuleName, "%s: The FreeQueue is NULL",__func__);
        return;
    }
    
    int workQueueSize = workQueue->size;
    if (workQueueSize > 0) {
        for (int i = 0; i < workQueueSize; i++) {
            KYLCustomQueueNode *node = DeQueue(workQueue);
            CFRelease(node->data);
            node->data = NULL;
            EnQueue(freeQueue, node);
        }
    }
    log4cplus_info(kModuleName, "%s: ResetFreeQueue : The work queue size is %d, free queue size is %d",__func__,workQueue->size, freeQueue->size);
}

void KYLQueue::ClearKYLCustomQueue(KYLCustomQueue *queue) {
    while (queue->size) {
        KYLCustomQueueNode *node = this->DeQueue(queue);
        this->FreeNode(node);
    }
    
    log4cplus_info(kModuleName, "%s: Clear KYLQueue queue",__func__);
}

void KYLQueue::FreeNode(KYLCustomQueueNode* node) {
    if(node != NULL){
        free(node->data);
        free(node);
    }
}
