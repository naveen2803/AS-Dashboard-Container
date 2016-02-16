/**
 * @author:	Naveen Malhotra
 * */
 
package container
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.effects.Move;
	import mx.effects.Parallel;
	import mx.effects.Resize;
	import mx.effects.easing.Exponential;
	import mx.events.DragEvent;
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
		
	public class canvasContainer extends Canvas
	{
		private var childrenList:Array = [];
		private var orignalX:int;
		private var orignalY:int;
		private var orignalHeight:int;
		private var orignalWidth:int;
		private var chartMaximised:Boolean = false;
		private var chartAnimating:Boolean = false;
		private var _podGap:int = 0;
		private var columns:Number;
		private var rows:Number;
		[Bindable] private var childHeight:int;
		[Bindable] private var childWidth:int;
		
		public function canvasContainer()
		{
			super();
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			this.addEventListener("Imgclick", onImageClick);
			this.addEventListener(DragEvent.DRAG_DROP, onDragComplete);
			this.addEventListener(DragEvent.DRAG_ENTER, onDragEnter);
		}
		
		// allow drop only in the canvas
		private function onDragEnter(e:DragEvent):void
		{
			if( e.dragSource.hasFormat( "panel" ) )
            {
                DragManager.acceptDragDrop( Canvas( e.currentTarget ) );
            }
		}
		// on drag complete swap the two panels
		private function onDragComplete(e:DragEvent):void
		{
			TitleBarPanel.isMouseDown = false;			
			if(!chartMaximised)
			{	
				for(var i:int = 0; i < childrenList.length; i++)
				{
					if((e.localX > childrenList[i].x && e.localX < (childrenList[i].x + childrenList[i].width )) && (e.localY > childrenList[i].y && e.localY < (childrenList[i].y + childrenList[i].height )))
					{
						var target1X:int;
						var target2X:int;
						var target1Y:int;
						var target2Y:int;
						var moveEffect1:Move = new Move();
						var moveEffect2:Move = new Move();
						moveEffect1.easingFunction = Exponential.easeOut;
						moveEffect2.easingFunction = Exponential.easeOut;
						target1X = e.dragInitiator.x;
						target2X = childrenList[i].x;
						target1Y = e.dragInitiator.y;
						target2Y = childrenList[i].y;
						moveEffect1.target = childrenList[i];
						moveEffect2.target = e.dragInitiator;
						moveEffect1.xTo = target1X;
						moveEffect2.xTo = target2X;
						moveEffect1.yTo = target1Y;
						moveEffect2.yTo = target2Y;
						moveEffect1.play();
						moveEffect2.play();
					}	
				}
			}
		}
		
		public function set setPodGap(podGap:int):void
		{
			_podGap = podGap;
		}
		
		public function get setPodGap():int
		{
			return _podGap;
		}
		
		// on maximize/restore button click
		private function onImageClick(e:MouseEvent):void
		{
			toggleMaximize_Minimize(e.target);
		}
		
		// create the children on creation complete
		// calculate rows and columns
		// measeure the height and width of each child in the container
		private function onCreationComplete(e:FlexEvent):void
		{		
			var calculactionCompleted:Boolean = false;
			for(var i:int = 1; i <= this.getChildren().length / 2 + 1; i++)
			{
				if(!calculactionCompleted)
				{
					for(var j:int = 1; j <= i; j++)
					{
						if(!calculactionCompleted)	
						{
							for(var k:int = 1; k <= i; k++)
							{
								if(j*k >= this.getChildren().length)
								{
									columns = k;
									rows = j;
									calculactionCompleted = true;
									break;
								}		
							}
						}
						else
						{
							break;
						}
					}
				}
				else
				{
					break;
				}
			}
			
			if(rows == 1)
			{
				_podGap = 0;
			}
			
			for(var ch:int = 0; ch < this.getChildren().length; ch++)
			{
				childrenList.push(this.getChildAt(ch));
			}
			
			childHeight = height/rows - ((rows - 1) * _podGap);//childHeight = height/rows
			childWidth = width/columns - ((columns - 1) * _podGap);//childWidth = width/columns
			manageChildren();
		}
		
		// position the children in the canvas
		private function manageChildren():void
		{
			for(var ch:int = 0; ch < childrenList.length; ch++)
			{			
				var positionX:int;
				var positionY:int;
				var rowNumber:int;
				var columnNumber:int;
				var childPosition:Number;
				
				
				rowNumber = ch / columns;
				if(rowNumber > 0)
				{
					columnNumber = ch - (rowNumber * columns);
				}
				else
				{
					columnNumber = ch;
				}
				
				positionX = columnNumber * width/columns + _podGap;//positionX = columnNumber * childWidth ;
				positionY = rowNumber * height/rows + _podGap;//positionY = rowNumber * childHeight ;
				
				var moveEffect:Move = new Move();
				moveEffect.target = this.getChildAt(ch);
				moveEffect.xTo = positionX;
				moveEffect.yTo = positionY;
				moveEffect.xFrom = width / 2;
				moveEffect.yFrom = height / 2;
				moveEffect.duration = 1000;
				moveEffect.easingFunction = Exponential.easeOut;
				moveEffect.play();
				
				this.getChildAt(ch).height = childHeight;
				this.getChildAt(ch).width = childWidth;
				this.getChildAt(ch).x = positionX;
				this.getChildAt(ch).y = positionY;
			}	
		}
		
		public function toggleMaximize_Minimize(item:Object):void
		{
			if(!chartAnimating)
			{	
				for(var i:int = 0; i < childrenList.length; i++)
				{
					if(childrenList[i] == item)
					{
						if(!chartMaximised)
						{
							orignalX = childrenList[i].x;
							orignalY = childrenList[i].y;
							orignalHeight = childrenList[i].height;
							orignalWidth = childrenList[i].width;
							
							setChildIndex(childrenList[i], getChildren().length - 1);
							var parallelEffect:Parallel = new Parallel();
							parallelEffect.addEventListener(EffectEvent.EFFECT_END, onEffectComplete);	
							var moveEffect:Move = new Move();
							moveEffect.xTo = 0;
							moveEffect.yTo = 0;
							moveEffect.target = childrenList[i];
							moveEffect.easingFunction = Exponential.easeOut;
							
							var resizeEffect:Resize = new Resize();
							resizeEffect.target = childrenList[i];
							resizeEffect.heightTo = height;
							resizeEffect.widthTo = width;
							resizeEffect.easingFunction = Exponential.easeOut;
							
							parallelEffect.addChild(moveEffect);
							parallelEffect.addChild(resizeEffect);
							parallelEffect.duration = 1000;
							parallelEffect.play();
							chartAnimating = true;
							chartMaximised = true;
							TitleBarPanel.isChartAnimating = true;
						}
						else
						{
							restoreChart(item);
						}
					}
				}
			}
		}
		
		private function restoreChart(item:Object):void
		{
			if(!chartAnimating)
			{	
				for(var i:int = 0; i < childrenList.length; i++)
				{
					if(childrenList[i] == item)
					{
						var parallelEffect:Parallel = new Parallel();
						parallelEffect.addEventListener(EffectEvent.EFFECT_END, onEffectComplete);	
						var moveEffect:Move = new Move();
						moveEffect.xTo = orignalX;
						moveEffect.yTo = orignalY;
						moveEffect.target = childrenList[i];
						moveEffect.easingFunction = Exponential.easeOut;
						
						var resizeEffect:Resize = new Resize();
						resizeEffect.target = childrenList[i];
						resizeEffect.heightTo = orignalHeight;
						resizeEffect.widthTo = orignalWidth;
						resizeEffect.easingFunction = Exponential.easeOut;
						
						parallelEffect.addChild(moveEffect);
						parallelEffect.addChild(resizeEffect);
						parallelEffect.duration = 1000;
						parallelEffect.play();
						chartAnimating = true;
						TitleBarPanel.isChartAnimating = true;
						chartMaximised = false;
					}
				}
			}
		}
		
		// on maximize / restore animation complete 
		private function onEffectComplete(e:EffectEvent):void
		{
			chartAnimating = false;
			TitleBarPanel.isChartAnimating = false;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// for auto adjust of the children in the window
			var oldChildHeight:int = childHeight;
			var oldChildWidth:int = childWidth;
			childHeight = height/rows - ((rows - 1) * _podGap);//childHeight = height/rows
			childWidth = width/columns - ((columns - 1) * _podGap);//childWidth = width/columns
			
			if(oldChildHeight != childHeight || oldChildWidth != childWidth)
			{	
				manageChildren();
				chartMaximised = false;
			}
			
		}
	}
}